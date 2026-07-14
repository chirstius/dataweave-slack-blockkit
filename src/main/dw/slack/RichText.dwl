/**
* Types and builder functions for the Slack `rich_text` block and its sub-blocks and inline
* elements. The rich_text block is the modern default for message formatting and supports
* structured styling, lists, quotes, code blocks, mentions, emoji, links and dates.
*
* https://docs.slack.dev/reference/block-kit/blocks/rich-text-block
*
* All builders return plain objects, so they compose with `slack::Builders` (e.g. drop a
* `richText(...)` block straight into `blocks([...])`).
*
* Example:
* [source,DataWeave]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* import * from slack::RichText
* ---
* blocks([
*   richText([
*     rtSection([ rtText("Hello "), rtUser("U123"), rtText("!") ]),
*     rtBulletList([
*       rtSection([ rtText("first") ]),
*       rtSection([ rtText("second") ])
*     ])
*   ])
* ])
* ----
*/
%dw 2.0
import mergeWith from dw::core::Objects

// ============================================================================================
//  Types
// ============================================================================================

/** A rich_text block: a container of rich-text sub-blocks. */
type RichTextBlock = {
    'type': "rich_text",
    elements: Array<RichTextElement>,
    block_id?: String
}

/** Union of the four rich-text sub-blocks that may appear in a rich_text block. */
type RichTextElement = RichTextSection | RichTextList | RichTextQuote | RichTextPreformatted

/** A run of inline elements. */
type RichTextSection = {
    'type': "rich_text_section",
    elements: Array<RichTextInline>
}

/** A bulleted or ordered list of rich_text_section entries. */
type RichTextList = {
    'type': "rich_text_list",
    style: "bullet" | "ordered",
    elements: Array<RichTextSection>,
    indent?: Number,
    offset?: Number,
    border?: Number
}

/** A block quote. */
type RichTextQuote = {
    'type': "rich_text_quote",
    elements: Array<RichTextInline>,
    border?: Number
}

/** A preformatted (code) block. */
type RichTextPreformatted = {
    'type': "rich_text_preformatted",
    elements: Array<RichTextInline>,
    border?: Number
}

/** Union of the inline elements that may appear inside a section, quote or preformatted block. */
type RichTextInline = RtText | RtChannel | RtUser | RtUserGroup | RtEmoji | RtLink | RtDate | RtBroadcast | RtColor

/** Style flags shared by most inline elements. Not every flag applies to every element. */
type RichTextStyle = {
    bold?: Boolean,
    italic?: Boolean,
    strike?: Boolean,
    code?: Boolean,
    underline?: Boolean,
    highlight?: Boolean,
    client_highlight?: Boolean,
    unlink?: Boolean
}

type RtText = {
    'type': "text",
    text: String,
    style?: RichTextStyle
}

type RtChannel = {
    'type': "channel",
    channel_id: String,
    style?: RichTextStyle
}

type RtUser = {
    'type': "user",
    user_id: String,
    style?: RichTextStyle
}

type RtUserGroup = {
    'type': "usergroup",
    usergroup_id: String,
    style?: RichTextStyle
}

type RtEmoji = {
    'type': "emoji",
    name: String,
    unicode?: String
}

type RtLink = {
    'type': "link",
    url: String,
    text?: String,
    style?: RichTextStyle
}

type RtDate = {
    'type': "date",
    timestamp: Number,
    format: String,
    url?: String,
    fallback?: String,
    style?: RichTextStyle
}

type RtBroadcast = {
    'type': "broadcast",
    range: "here" | "channel" | "everyone"
}

type RtColor = {
    'type': "color",
    value: String
}

// ============================================================================================
//  Block / sub-block builders
// ============================================================================================

/** Builds a rich_text block from its sub-blocks. */
fun richText(elements: Array<RichTextElement>) : RichTextBlock = {
    'type': "rich_text",
    elements: elements
}

/** Builds a rich_text_section (a run of inline elements). */
fun rtSection(elements: Array<RichTextInline>) : RichTextSection = {
    'type': "rich_text_section",
    elements: elements
}

/** Builds a bulleted list from an array of sections. */
fun rtBulletList(sections: Array<RichTextSection>) : RichTextList = {
    'type': "rich_text_list",
    style: "bullet",
    elements: sections
}

/** Builds an ordered (numbered) list from an array of sections. */
fun rtOrderedList(sections: Array<RichTextSection>) : RichTextList = {
    'type': "rich_text_list",
    style: "ordered",
    elements: sections
}

/** Builds a block quote from inline elements. */
fun rtQuote(elements: Array<RichTextInline>) : RichTextQuote = {
    'type': "rich_text_quote",
    elements: elements
}

/** Builds a preformatted (code) block from inline elements. */
fun rtPreformatted(elements: Array<RichTextInline>) : RichTextPreformatted = {
    'type': "rich_text_preformatted",
    elements: elements
}

// ============================================================================================
//  Inline element builders
// ============================================================================================

/** Plain inline text. */
fun rtText(txt: String) : RtText = {
    'type': "text",
    text: txt
}

/** Styled inline text (pass e.g. `{ bold: true }`). */
fun rtText(txt: String, style: RichTextStyle) : RtText = {
    'type': "text",
    text: txt,
    style: style
}

/** A channel mention by channel id. */
fun rtChannel(channelId: String) : RtChannel = {
    'type': "channel",
    channel_id: channelId
}

/** A user mention by user id. */
fun rtUser(userId: String) : RtUser = {
    'type': "user",
    user_id: userId
}

/** A user-group mention by usergroup id. */
fun rtUserGroup(usergroupId: String) : RtUserGroup = {
    'type': "usergroup",
    usergroup_id: usergroupId
}

/** An emoji by name (e.g. "wave"). */
fun rtEmoji(name: String) : RtEmoji = {
    'type': "emoji",
    name: name
}

/** A hyperlink. */
fun rtLink(url: String) : RtLink = {
    'type': "link",
    url: url
}

/** A hyperlink with custom display text. */
fun rtLink(url: String, txt: String) : RtLink = {
    'type': "link",
    url: url,
    text: txt
}

/** A formatted date from a Unix timestamp (seconds) and a Slack date format string. */
fun rtDate(timestamp: Number, format: String) : RtDate = {
    'type': "date",
    timestamp: timestamp,
    format: format
}

/** A broadcast mention: one of "here", "channel" or "everyone". */
fun rtBroadcast(range: "here" | "channel" | "everyone") : RtBroadcast = {
    'type': "broadcast",
    range: range
}

/** An inline color swatch from a hex value (e.g. "#ff0000"). */
fun rtColor(hex: String) : RtColor = {
    'type': "color",
    value: hex
}

/** Applies (or overrides) the `style` object on any inline element that supports one. */
fun withRichTextStyle(inline: Object, style: RichTextStyle) = inline mergeWith {style: style}
