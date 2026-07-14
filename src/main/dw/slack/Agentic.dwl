/**
* Builders for Slack's newer "agentic" / AI-app Block Kit surface: cards, carousels, containers,
* tables, data tables, data visualizations, alerts, plans, task cards, and the context-action
* elements (feedback buttons, icon buttons, url sources).
*
* WARNING:  EXPERIMENTAL / LIMITED AVAILABILITY. These blocks are newer than the core Block Kit surface
*     and are not generally available in every workspace or on every surface (e.g. alert blocks
*     are modal-only; several render only for AI apps). Their schemas can change. This module is
*     kept separate from `slack::Builders` so the stable core stays clean. Where a schema is in
*     flux, prefer the generic `agenticBlock(type, fields)` escape hatch.
*
* https://docs.slack.dev/reference/block-kit/blocks
*
* Builders accept plain Strings for text fields and wrap them as Slack text objects; pass an
* explicit object (or use a `with*` modifier) when you need finer control.
*/
%dw 2.0
import * from slack::Builders
import mergeWith from dw::core::Objects

// ============================================================================================
//  Generic escape hatch
// ============================================================================================

/**
* Builds an arbitrary block from a `type` string and a fields object. Use for any newer block
* whose dedicated builder does not yet exist or whose schema has changed upstream.
*
* [source,DataWeave]
* ----
* agenticBlock("alert", { text: mrkdwn("Heads up"), level: "warning" })
* ----
*/
fun agenticBlock(blockType: String, fields: Object) = { 'type': blockType } ++ fields

// ============================================================================================
//  Cell helpers (for table / data_table blocks)
// ============================================================================================

/** A raw (unstyled) text table cell. */
fun rawText(txt: String) = { 'type': "raw_text", text: txt }

/** A raw numeric table cell. (Field name per Slack's data-table spec; use `rawText` if unsure.) */
fun rawNumber(value: Number) = { 'type': "raw_number", number: value }

// ============================================================================================
//  Context-action elements
// ============================================================================================

/**
* A feedback buttons element (thumbs up / thumbs down by default), for use inside a
* context_actions block.
*
* https://docs.slack.dev/reference/block-kit/block-elements/feedback-buttons-element
*/
fun feedbackButtons(id: String, positiveValue: String, negativeValue: String) = {
    'type': "feedback_buttons",
    action_id: id,
    positive_button: {
        text: text(":thumbsup:"),
        value: positiveValue
    },
    negative_button: {
        text: text(":thumbsdown:"),
        value: negativeValue
    }
}

/**
* An icon button element, for use inside a context_actions block.
*
* https://docs.slack.dev/reference/block-kit/block-elements/icon-button-element
*/
fun iconButton(id: String, icon: String, ariaLabel: String) = {
    'type': "icon_button",
    action_id: id,
    icon: icon,
    aria_label: ariaLabel
}

/**
* A URL source element (referenced by task cards' `sources`).
*
* https://docs.slack.dev/reference/block-kit/block-elements/url-source-element
*/
fun urlSource(url: String) = {
    'type': "url_source",
    url: url
}

// ============================================================================================
//  Card & carousel
// ============================================================================================

/**
* Builds a card block. At least one of title/body/actions/hero image is required by Slack.
* This convenience form sets a mrkdwn title and body; layer more with the `withCard*` modifiers
* or use `agenticBlock("card", {...})` for full control.
*
* https://docs.slack.dev/reference/block-kit/blocks/card-block
*/
fun card(title: String, body: String) = {
    'type': "card",
    title: mrkdwn(title),
    body: mrkdwn(body)
}

/** Adds a subtitle to a card. */
fun withCardSubtitle(card: Object, subtitle: String) = card mergeWith {subtitle: mrkdwn(subtitle)}

/** Adds subtext (footer-style) to a card. */
fun withCardSubtext(card: Object, subtext: String) = card mergeWith {subtext: mrkdwn(subtext)}

/** Adds a hero image (an image element) to a card. */
fun withCardHeroImage(card: Object, url: String, altText: String) = card mergeWith {hero_image: image(url, altText)}

/** Adds an icon (an image element) to a card. */
fun withCardIcon(card: Object, url: String, altText: String) = card mergeWith {icon: image(url, altText)}

/** Adds an actions block to a card. */
fun withCardActions(card: Object, elements: Array<Any>) = card mergeWith {actions: {'type': "actions", elements: elements}}

/**
* Builds a carousel block from an array of card objects (1-10 cards).
*
* https://docs.slack.dev/reference/block-kit/blocks/carousel-block
*/
fun carousel(cards: Array<Any>) = {
    'type': "carousel",
    elements: cards
}

// ============================================================================================
//  Container
// ============================================================================================

/**
* Builds a container block that groups up to 10 child blocks under a title.
*
* https://docs.slack.dev/reference/block-kit/blocks/container-block
*/
fun container(title: String, childBlocks: Array<Any>) = {
    'type': "container",
    title: text(title),
    child_blocks: childBlocks
}

/** Sets container width: "narrow" | "standard" | "wide" | "full". */
fun withContainerWidth(container: Object, width: String) = container mergeWith {width: width}

/** Makes a container collapsible (optionally collapsed by default). */
fun withContainerCollapsible(container: Object, collapsible: Boolean = true, defaultCollapsed: Boolean = false) =
    container mergeWith {is_collapsible: collapsible, default_collapsed: defaultCollapsed}

// ============================================================================================
//  Context actions
// ============================================================================================

/**
* Builds a context_actions block (up to 5 feedback/icon-button elements).
*
* https://docs.slack.dev/reference/block-kit/blocks/context-actions-block
*/
fun contextActions(elements: Array<Any>) = {
    'type': "context_actions",
    elements: elements
}

// ============================================================================================
//  Tables
// ============================================================================================

/**
* Builds a table block from rows. Each row is an array of cells built with `rawText`,
* `rawNumber`, or a rich_text object. Up to 100 rows x 20 columns; 10,000 chars total.
*
* https://docs.slack.dev/reference/block-kit/blocks/table-block
*/
fun table(rows: Array<Array<Any>>) = {
    'type': "table",
    rows: rows
}

/** Adds per-column settings (align / is_wrapped) to a table. */
fun withColumnSettings(table: Object, settings: Array<Any>) = table mergeWith {column_settings: settings}

/** Builds a single column setting: align is "left" | "center" | "right". */
fun columnSetting(align: String, isWrapped: Boolean = false) = { align: align, is_wrapped: isWrapped }

/**
* Builds a data_table block (paginated, sortable table) with a caption and rows.
*
* https://docs.slack.dev/reference/block-kit/blocks/data-table-block
*/
fun dataTable(caption: String, rows: Array<Array<Any>>) = {
    'type': "data_table",
    caption: caption,
    rows: rows
}

/** Sets the page size (rows per page, 1-100) on a data_table. */
fun withPageSize(dataTable: Object, pageSize: Number) = dataTable mergeWith {page_size: pageSize}

// ============================================================================================
//  Data visualization
// ============================================================================================

/**
* Builds a data_visualization block from a title and a chart object (see `pieChart` / `chart`).
*
* https://docs.slack.dev/reference/block-kit/blocks/data-visualization-block
*/
fun dataVisualization(title: String, chart: Object) = {
    'type': "data_visualization",
    title: title,
    chart: chart
}

/** Builds a pie chart payload from an array of `{ label, value }` segments. */
fun pieChart(segments: Array<Any>) = {
    'type': "pie",
    segments: segments
}

/** Generic chart payload builder for "pie" | "bar" | "area" | "line". */
fun chart(chartType: String, fields: Object) = { 'type': chartType } ++ fields

// ============================================================================================
//  Alerts
// ============================================================================================

/**
* Builds an alert block (modal-only). `level` is one of default|info|warning|error|success.
*
* https://docs.slack.dev/reference/block-kit/blocks/alert-block
*/
fun alert(message: String, level: String = "default") = {
    'type': "alert",
    text: mrkdwn(message),
    level: level
}

// ============================================================================================
//  Plans & task cards
// ============================================================================================

/**
* Builds a plan block from a title and a sequence of task-card entries.
*
* https://docs.slack.dev/reference/block-kit/blocks/plan-block
*/
fun plan(title: String, tasks: Array<Any>) = {
    'type': "plan",
    title: title,
    tasks: tasks
}

/**
* Builds a task_card block. `status` is one of pending|in_progress|complete|error.
*
* https://docs.slack.dev/reference/block-kit/blocks/task-card-block
*/
fun taskCard(taskId: String, title: String, status: String = "pending") = {
    'type': "task_card",
    task_id: taskId,
    title: title,
    status: status
}

/** Adds rich_text `details` to a task card. */
fun withTaskDetails(taskCard: Object, details: Object) = taskCard mergeWith {details: details}

/** Adds rich_text `output` to a task card. (`output` is a DataWeave reserved word -- quoted.) */
fun withTaskOutput(taskCard: Object, taskOutput: Object) = taskCard mergeWith {"output": taskOutput}

/** Adds an array of url_source `sources` to a task card. */
fun withTaskSources(taskCard: Object, sources: Array<Any>) = taskCard mergeWith {sources: sources}
