/**
* Guardrails for Slack Block Kit content limits. Slack rejects a whole payload if any field
* exceeds its limit, which is easy to trip when the content comes from an LLM/agent, a database,
* or user input. This module lets you decide, per call, what happens on overflow:
*
*   - "error"    : fail fast with a clear message (default for single-line fields)
*   - "truncate" : cut to the limit (on a word boundary where possible), append an ellipsis
*   - "split"    : smartly split across multiple blocks / messages (default where splitting is valid)
*
* IMPORTANT distinction between the two kinds of limit:
*   - PER-BLOCK limits (e.g. section text = 3,000): splitting into more blocks genuinely helps.
*     Use `sectionBlocks`.
*   - CUMULATIVE-PER-PAYLOAD limits (e.g. markdown block text = 12,000 across ALL markdown blocks
*     in one payload): adding more blocks does NOT buy more budget, so you must paginate across
*     multiple MESSAGES. Use `markdownMessages`.
*
* The smart splitter (`chunkText`) breaks on the coarsest boundary that fits -- paragraphs
* (blank line), then lines, then spaces, and only hard-cuts mid-token as a last resort -- so
* markdown structure (headings, tables, code fences) survives splitting as much as possible.
*
* https://docs.slack.dev/reference/block-kit
*/
%dw 2.0
import * from slack::Builders
import fail from dw::Runtime

// ============================================================================================
//  Limit constants (characters, unless noted)
// ============================================================================================

/** Max length of a section block's `text` (mrkdwn/plain_text), per block. */
var SECTION_TEXT_MAX_LENGTH = 3000
/** Max length of each item in a section block's `fields` array. */
var SECTION_FIELD_MAX_LENGTH = 2000
/** Max number of items in a section block's `fields` array. */
var SECTION_FIELDS_MAX = 10
/** Cumulative max of `markdown` block `text` across ALL markdown blocks in a single payload. */
var MARKDOWN_MAX_LENGTH = 12000
/** Max length of a header block's `text`. */
var HEADER_MAX_LENGTH = 150
/** Max length of a button's `text`. */
var BUTTON_TEXT_MAX_LENGTH = 75
/** Max number of elements in a context block. */
var CONTEXT_ELEMENTS_MAX = 10
/** Max number of elements in an actions block. */
var ACTIONS_ELEMENTS_MAX = 25
/** Max length of an option's `text`. */
var OPTION_TEXT_MAX_LENGTH = 75
/** Max number of options in a select / multi-select / checkbox / radio group. */
var SELECT_OPTIONS_MAX = 100
/** Max blocks in a single message payload. */
var MESSAGE_MAX_BLOCKS = 50
/** Max blocks in a modal or App Home surface. */
var SURFACE_MAX_BLOCKS = 100

/** How to handle content that exceeds a limit. */
type OverflowPolicy = "error" | "truncate" | "split"

// ============================================================================================
//  Text utilities
// ============================================================================================

/** Hard-splits a string into fixed-size pieces of at most `maxLen` characters (last resort). */
fun hardSplit(text: String, maxLen: Number): Array<String> =
    if (sizeOf(text) <= maxLen) [text]
    else [text[0 to maxLen - 1]] ++ hardSplit(text[maxLen to -1] default "", maxLen)

/** Greedily packs segments (rejoined with `sep`) into chunks of at most `maxLen` characters. */
fun packSegments(segments: Array<String>, sep: String, maxLen: Number): Array<String> = do {
    var folded = segments reduce ((seg, acc = { done: [], cur: null }) ->
        if (acc.cur == null)
            { done: acc.done, cur: seg }
        else do {
            var candidate = acc.cur ++ sep ++ seg
            ---
            if (sizeOf(candidate) <= maxLen)
                { done: acc.done, cur: candidate }
            else
                { done: (acc.done << acc.cur), cur: seg }
        }
    )
    ---
    folded.done ++ (if (folded.cur == null) [] else [folded.cur as String])
}

/**
* Smartly splits `text` into chunks of at most `maxLen` characters, breaking on the coarsest
* boundary that fits: paragraphs (blank line), then lines, then spaces, then a hard cut. Keeps
* markdown structure intact as far as possible.
*/
fun chunkText(text: String, maxLen: Number): Array<String> =
    chunkWith(text, maxLen, ["\n\n", "\n", " "])

fun chunkWith(text: String, maxLen: Number, seps: Array<String>): Array<String> =
    if (sizeOf(text) <= maxLen)
        [text]
    else if (isEmpty(seps))
        hardSplit(text, maxLen)
    else do {
        var sep = seps[0]
        var finer = seps[1 to -1] default []
        var segments = text splitBy sep
        ---
        if (sizeOf(segments) <= 1)
            chunkWith(text, maxLen, finer)
        else
            packSegments(segments, sep, maxLen) flatMap ((chunk) ->
                if (sizeOf(chunk) <= maxLen) [chunk]
                else chunkWith(chunk, maxLen, finer)
            )
    }

/** Truncates `text` to at most `maxLen` chars, appending `ellipsis` within the budget. */
fun truncateText(text: String, maxLen: Number, ellipsis: String = "..."): String =
    if (sizeOf(text) <= maxLen) text
    else if (maxLen <= sizeOf(ellipsis)) text[0 to maxLen - 1] default ""
    else (text[0 to (maxLen - sizeOf(ellipsis) - 1)] default "") ++ ellipsis

/**
* Applies an overflow policy to a single string against `maxLen`, returning the resulting
* chunk(s). "split" may return multiple; "truncate" returns one; "error" fails if over limit.
*/
fun applyOverflow(text: String, maxLen: Number, policy: OverflowPolicy, label: String): Array<String> =
    if (sizeOf(text) <= maxLen)
        [text]
    else policy match {
        case "split" -> chunkText(text, maxLen)
        case "truncate" -> [truncateText(text, maxLen)]
        case "error" -> fail("Slack $(label) exceeds its $(maxLen)-character limit (was $(sizeOf(text))). Shorten the content or use policy 'split' or 'truncate'.")
        else -> [text]
    }

/**
* Guards a value that lives on a single-line field (no splitting possible): "truncate" (default)
* cuts to `maxLen`, "error" fails. "split" is treated as "truncate" here since the field is atomic.
*/
fun guardLine(text: String, maxLen: Number, policy: OverflowPolicy, label: String): String =
    if (sizeOf(text) <= maxLen) text
    else if (policy == "error")
        fail("Slack $(label) exceeds its $(maxLen)-character limit (was $(sizeOf(text))). Shorten the content or use policy 'truncate'.")
    else truncateText(text, maxLen)

// ============================================================================================
//  Guard-aware builders
// ============================================================================================

/**
* Builds one or more `section` blocks from `text`, keeping each block's mrkdwn under the 3,000-
* character per-block limit. With policy "split" (default) long text is smartly divided across
* multiple sections; "truncate" yields a single truncated section; "error" fails if over limit.
*/
fun sectionBlocks(text: String, policy: OverflowPolicy = "split"): Array<Any> =
    applyOverflow(text, SECTION_TEXT_MAX_LENGTH, policy, "section text") map ((chunk) -> section(chunk))

/**
* Builds one or more `message` payloads, each carrying a single `markdown` block, so an LLM/agent
* response respects the 12,000-character cumulative markdown limit. With policy "split" (default)
* a long response is paginated across multiple messages (post them in sequence / in-thread);
* "truncate" yields a single truncated message; "error" fails if over limit.
*
* Each returned payload is a bare `{ blocks: [...] }`; chain `withChannel` / `withThreadTs` /
* `withText` from slack::Views onto each as needed.
*/
fun markdownMessages(text: String, policy: OverflowPolicy = "split"): Array<Any> =
    applyOverflow(text, MARKDOWN_MAX_LENGTH, policy, "markdown block text") map ((chunk) -> { blocks: [ markdownBlock(chunk) ] })

/**
* Builds a `header` block, guarding the 150-character single-line limit. Policy "truncate"
* (default) cuts overly long titles; "error" fails.
*/
fun safeHeader(text: String, policy: OverflowPolicy = "truncate"): Any =
    header(guardLine(text, HEADER_MAX_LENGTH, policy, "header text"))

/**
* Builds a `button`, guarding the 75-character label limit. Policy "truncate" (default) or "error".
*/
fun safeButton(text: String, id: String, policy: OverflowPolicy = "truncate"): Any =
    button(guardLine(text, BUTTON_TEXT_MAX_LENGTH, policy, "button text"), id)

/** Splits an array into sub-arrays of at most `size` items each. */
fun chunkArray(items: Array<Any>, size: Number): Array<Array<Any>> =
    if (sizeOf(items) <= size) [items]
    else [items[0 to size - 1]] ++ chunkArray(items[size to -1] default [], size)

/**
* Applies an overflow policy to an array against a maximum item COUNT, returning the resulting
* group(s). "split" chunks into multiple groups of <= maxCount; "truncate" keeps the first
* maxCount in one group; "error" fails if over the limit.
*/
fun applyCount(items: Array<Any>, maxCount: Number, policy: OverflowPolicy, label: String): Array<Array<Any>> =
    if (sizeOf(items) <= maxCount)
        [items]
    else policy match {
        case "split" -> chunkArray(items, maxCount)
        case "truncate" -> [items[0 to maxCount - 1]]
        case "error" -> fail("Slack $(label) has $(sizeOf(items)) items, exceeding the limit of $(maxCount). Use policy 'split' or 'truncate'.")
        else -> [items]
    }

/**
* Builds one or more `section` blocks from an array of field strings, guarding BOTH the per-field
* 2,000-character limit and the 10-fields-per-section limit. Each string becomes a mrkdwn field
* (over-long fields are truncated, or fail under "error"); fields beyond 10 spill into additional
* section blocks under "split" (default), are dropped under "truncate", or fail under "error".
*/
fun fieldSections(fields: Array<String>, policy: OverflowPolicy = "split"): Array<Any> = do {
    var guarded = fields map ((f) -> mrkdwn(guardLine(f, SECTION_FIELD_MAX_LENGTH, if (policy == "error") "error" else "truncate", "section field text")))
    ---
    applyCount(guarded, SECTION_FIELDS_MAX, policy, "section fields") map ((group) -> { "type": "section", fields: group })
}

/**
* Builds one or more `context` blocks from an array of elements (text/image), keeping each block
* within the 10-element limit. "split" (default) spills into more context blocks; "truncate"
* keeps the first 10; "error" fails if over.
*/
fun contextBlocks(elements: Array<Any>, policy: OverflowPolicy = "split"): Array<Any> =
    applyCount(elements, CONTEXT_ELEMENTS_MAX, policy, "context elements") map ((group) -> { "type": "context", elements: group })

/**
* Builds one or more `actions` blocks from an array of interactive elements, keeping each block
* within the 25-element limit. "split" (default) spills into more actions blocks; "truncate"
* keeps the first 25; "error" fails if over.
*/
fun actionsBlocks(elements: Array<Any>, policy: OverflowPolicy = "split"): Array<Any> =
    applyCount(elements, ACTIONS_ELEMENTS_MAX, policy, "actions elements") map ((group) -> { "type": "actions", elements: group })

/**
* Splits a flat array of blocks into pages that each fit within `maxPerPage` blocks (defaults to
* the 50-block message limit; pass `SURFACE_MAX_BLOCKS` for modals/home). Post each page as its
* own message, or use only the first page for a surface.
*/
fun paginateBlocks(blocks: Array<Any>, maxPerPage: Number = MESSAGE_MAX_BLOCKS): Array<Array<Any>> =
    chunkArray(blocks, maxPerPage)

/**
* Asserts an array is within a block-count limit, returning it unchanged or failing with a clear
* message. Handy as a final check before returning a payload.
*/
fun assertBlockCount(blocks: Array<Any>, max: Number = MESSAGE_MAX_BLOCKS): Array<Any> =
    if (sizeOf(blocks) <= max) blocks
    else fail("Slack payload has $(sizeOf(blocks)) blocks, exceeding the limit of $(max). Use paginateBlocks to split across messages.")
