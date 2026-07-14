/**
*
* Types that represent all Slack Blocks. 
*
* https://api.slack.com/reference/block-kit/blocks[Slack Blocks Reference]
*/

%dw 2.0
import * from slack::Elements
import * from slack::Objects

/**
* Generic representation of a Slack block.
*/
type Block = OptionalId & {
    'type': String
}

/**
* Representation of a Slack action block.
*
* https://api.slack.com/reference/block-kit/blocks#actions[Actions Reference]
*/
type Actions = OptionalId & {
    'type': "actions",
    elements: Array<Element>
}

/**
* Representation of a Slack context block.
*
* https://api.slack.com/reference/block-kit/blocks#context[Context Reference]
*/
type Context = OptionalId & {
    'type': "context",
    elements: Array<Image|Text>
}

/**
* Representation of a Slack divider block.
*
* https://api.slack.com/reference/block-kit/blocks#divider[Divider Reference]
*/
type Divider = OptionalId & {
    'type': "divider"
}

/**
* Representation of a Slack file block.
*
* https://api.slack.com/reference/block-kit/blocks#file[File Reference]
*/
type File = OptionalId & {
    'type': "file",
    source: "remote",
    external_id: String
}

/**
* Representation of a Slack header block.
*
* https://api.slack.com/reference/block-kit/blocks#header[Header Reference]
*/
type Header = OptionalId & {
    'type': "header",
    text: PlainText
}

/**
* Representation of a Slack image block.
*
* https://api.slack.com/reference/block-kit/blocks#image[Image Reference]
*/
type ImageBlock = OptionalId & Image & {
    title?: PlainText
}

/**
* Representation of a Slack input block.
*
* https://api.slack.com/reference/block-kit/blocks#input[Input Reference]
*/
type Input = OptionalId & {
    'type': "input",
    label: PlainText,
    element: Element,
    dispatch_action?: Boolean,
    hint?: PlainText,
    optiona?: Boolean
}

/**
* Representation of a Slack section block.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Reference]
*/
type Section = (OptionalId & WithText | OptionalId & WithFields) & {
    'type': "section",
    accessory?: Element
}

/**
* Helper type to reuse text. 
*/
type WithText = {
    text: Text
}

/**
* Helper type to encapsulate fields
*/
type WithFields = {
    fields: Array<Text>
}

/**
* Representation of a Slack video block.
*
* https://docs.slack.dev/reference/block-kit/blocks/video-block
*/
type VideoBlock = OptionalId & {
    'type': "video",
    alt_text: String,
    title: PlainText,
    thumbnail_url: String,
    video_url: String,
    author_name?: String,
    description?: PlainText,
    provider_icon_url?: String,
    provider_name?: String,
    title_url?: String
}

/**
* Representation of a Slack `markdown` block.
*
* This is the full GitHub-flavored-markdown block (distinct from the `mrkdwn` *text object* used
* by sections). It is the block designed for rendering an LLM/agent's markdown response and
* supports headings, tables, task lists, ordered/unordered lists, block quotes, horizontal
* dividers, inline code, and fenced code blocks with syntax highlighting -- none of which the
* `mrkdwn` text object supports.
*
* `text` has a cumulative limit of 12,000 characters across all markdown blocks in one payload.
* `block_id` is accepted but ignored (not retained) by Slack for markdown blocks.
*
* https://docs.slack.dev/reference/block-kit/blocks/markdown-block
*/
type MarkdownBlock = OptionalId & {
    'type': "markdown",
    text: String
}

/**
* Helper type to reuse a block with optional IDs.
*/
type OptionalId = {
    block_id?: String
}
