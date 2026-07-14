/**
* Builders for Slack *surfaces* -- App Home and Modal views -- and for message payloads, plus the
* API request envelopes used to publish/open them. These wrap the boilerplate that consumers
* would otherwise hand-roll (view type, title objects, submit/close buttons, publish payloads).
*
* - Views: https://docs.slack.dev/surfaces/app-home , https://docs.slack.dev/surfaces/modals
* - Messages: https://docs.slack.dev/messaging/formatting-message-text
*
* Example:
* [source,DataWeave]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* import * from slack::Views
* ---
* publishHomeView("U0123", [ header("Welcome"), section("Hello!") ])
* ----
*/
%dw 2.0
import * from slack::Builders
import mergeWith from dw::core::Objects

// ============================================================================================
//  View objects
// ============================================================================================

/** Builds a `home` view object from an array of blocks. */
fun homeView(blocks: Array<Any>) = {
    'type': "home",
    blocks: blocks
}

/** Builds a `modal` view object with a plain-text title and an array of blocks. */
fun modalView(title: String, blocks: Array<Any>) = {
    'type': "modal",
    title: text(title),
    blocks: blocks
}

// --- view modifiers ---

/** Adds a submit button (modals only). */
fun withSubmit(view: Object, label: String) = view mergeWith {submit: text(label)}

/** Adds a close button (modals only). */
fun withClose(view: Object, label: String) = view mergeWith {close: text(label)}

/** Sets the `callback_id` used to route view submissions. */
fun withCallbackId(view: Object, id: String) = view mergeWith {callback_id: id}

/** Attaches opaque `private_metadata` echoed back on interactions. */
fun withPrivateMetadata(view: Object, metadata: String) = view mergeWith {private_metadata: metadata}

/** Sets an `external_id` for the view. */
fun withExternalId(view: Object, id: String) = view mergeWith {external_id: id}

/** Requests a `view_closed` event when the modal is dismissed. */
fun withNotifyOnClose(view: Object, notify: Boolean = true) = view mergeWith {notify_on_close: notify}

/** Clears the entire view stack when the modal is closed. */
fun withClearOnClose(view: Object, clear: Boolean = true) = view mergeWith {clear_on_close: clear}

// ============================================================================================
//  API request envelopes
// ============================================================================================

/**
* Builds the `views.publish` request payload for App Home, wrapping a home view around the
* given blocks for the given user.
*
* https://docs.slack.dev/reference/methods/views.publish
*/
fun publishHomeView(userId: String, blocks: Array<Any>) = {
    user_id: userId,
    view: homeView(blocks)
}

/**
* Builds the `views.open` request payload from a trigger id and a view object.
*
* https://docs.slack.dev/reference/methods/views.open
*/
fun openView(triggerId: String, view: Object) = {
    trigger_id: triggerId,
    view: view
}

/**
* Builds the `views.update` request payload from a view id and a view object.
*
* https://docs.slack.dev/reference/methods/views.update
*/
fun updateView(viewId: String, view: Object) = {
    view_id: viewId,
    view: view
}

// ============================================================================================
//  Message payloads
// ============================================================================================

/**
* Builds a message payload from an array of blocks. Chain `withChannel`, `withThreadTs`,
* `withText` (fallback/notification text) and `withResponseType` as needed.
*
* https://docs.slack.dev/messaging/sending-and-scheduling-messages
*/
fun message(blocks: Array<Any>) = {
    blocks: blocks
}

/**
* Builds a message payload that renders a single full-markdown block -- the ergonomic path for
* posting an LLM/agent's markdown response (headings, tables, task lists, fenced code, etc.).
* Chain `withChannel` / `withThreadTs` / `withText` as needed.
*
* [source,DataWeave]
* ----
* markdownMessage(agentResponse) withChannel "C0123" withText "Agent reply"
* ----
*
* https://docs.slack.dev/reference/block-kit/blocks/markdown-block
*/
fun markdownMessage(markdownText: String) = {
    blocks: [ markdownBlock(markdownText) ]
}

/** Sets the target `channel` on a message payload. */
fun withChannel(msg: Object, channel: String) = msg mergeWith {channel: channel}

/** Posts the message as a threaded reply to the given parent `thread_ts`. */
fun withThreadTs(msg: Object, threadTs: String) = msg mergeWith {thread_ts: threadTs}

/** Sets the top-level `text` (fallback / notification text) on a message payload. */
fun withText(msg: Object, txt: String) = msg mergeWith {text: txt}

/** Sets the `response_type` ("in_channel" or "ephemeral") for a response_url reply. */
fun withResponseType(msg: Object, responseType: String) = msg mergeWith {response_type: responseType}

/** Marks a response_url reply to `replace_original` the invoking message. */
fun withReplaceOriginal(msg: Object, replace: Boolean = true) = msg mergeWith {replace_original: replace}
