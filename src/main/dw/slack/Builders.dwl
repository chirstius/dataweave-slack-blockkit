/**
* Provides functions to simplify the creation and composition of these Slack API features:
*
* - https://api.slack.com/block-kit[Blocks]
* - https://api.slack.com/reference/block-kit/block-elements[Elements]
* - https://api.slack.com/reference/block-kit/composition-objects[Objects]
*/

%dw 2.0
import * from slack::Blocks
import * from slack::Elements
import * from slack::Objects
import mergeWith from dw::core::Objects

/**
* Generates the standard Block Kit syntax to define a group of blocks.
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `blocks` | `Array<Block&#62;` | The array of blocks to render.
* |===
*
* === Example
*
* This example generates and uses a simple section as a block.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  blocks([section("Hello there!")])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*    "blocks": [
*     {
*        "type": "section",
*        "text": {
*          "type": "plain_text",
*          "text": "Hello there!",
*          "emoji": true
*        }
*      }
*    ]
* }
* ----
*/
fun blocks(blocks: Array<Block>) = {
    blocks: blocks
}

/**
*  Generates an actions block.
*
* https://api.slack.com/reference/block-kit/blocks#actions[Actions Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `actions` | `Array<Element&#62;` | The array of interactive elements to render.
* |===
*
* === Example
*
* This examples generates an actions block with a simple button.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
* actions([button("Click me!", "bait")])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "actions",
*   "elements": [
*     {
*       "type": "button",
*       "text": {
*         "type": "plain_text",
*         "text": "Click me!",
*         "emoji": true
*       },
*       "action_id": "bait"
*     }
*   ]
* }
* ----
*/
fun actions(actions: Array<Element>) : Actions = {
    'type': "actions",
    elements: actions
}

/**
*  Generates a divider block.
*
* https://api.slack.com/reference/block-kit/blocks#divider[Divider Block Reference]
*
* === Example
*
* This example generates a divider block.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  divider()
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "divider"
* }
* ----
*/
fun divider() : Divider = {
    'type': "divider"
}

/**
*  Generates a plain text object with emojis enabled.
*
* https://api.slack.com/reference/block-kit/composition-objects#text[Text Object Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The text to use.
* |===
*
* === Example
*
* This example generates a text object that has a wave emoji.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  text("Hello! :wave:")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "plain_text",
*   "text": "Hello! :wave:",
*   "emoji": true
* }
* ----
*/
fun text(message : String) : PlainText = {
    'type': "plain_text",
    text: message,
    emoji: true
}

/**
*  Generates a mrkdwn text object.
*
* https://api.slack.com/reference/block-kit/composition-objects#text[Text Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The mrkdwn to use.
* |===
*
* === Example
*
* This example generates a mrkdwn text object that has bold text.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  mrkdwn("*Hello*")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "mrkdwn",
*   "text": "*Hello*"
* }
* ----
*/
fun mrkdwn(message: String) : Mrkdwn = {
    'type': "mrkdwn",
    text: message
}

/**
*  Generates a simple section block with a mrkdwn object.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired mrkdwn text.
* |===
*
* === Example
*
* This example generates a section with mrkdwn text.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  section("Hello!")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "section",
*   "text": {
*     "type": "mrkdwn",
*     "text": "Hello!"
*   }
* }
* ----
*/
fun section(message: String) : Section = section(mrkdwn(message))

/**
*  Generates a section block with a text object.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `Text` | The text object to use.
* |===
*
* === Example
*
* This example generates a section with mrkdwn text.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  section(mrkdwn("*Hello*"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "section",
*   "text": {
*     "type": "mrkdwn",
*     "text": "*Hello*"
*   }
* }
* ----
*/
fun section(text : Text) : Section = {
    'type': "section",
    text: text
}

/**
* Generates a section block with a mrkdwn text object and an accessory element.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired mrkdwn text.
* | `accessory` | `Element` | The element to use.
* |===
*
* === Example
*
* This example generates a section with simple text and a simple button.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* section("*Tim's Farewell Party* is tonight at 8 PM", button("RSVP", "invite"))
*
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*     "type": "section",
*     "text": {
*       "type": "mrkdwn",
*       "text": "*Tim's Farewell Party* is tonight at 8 PM"
*     },
*     "accessory": {
*       "type": "button",
*       "text": {
*         "type": "plain_text",
*         "text": "RSVP",
*         "emoji": true
*       },
*       "action_id": "invite"
*     }
*   }
* ----
**/
fun section(message: String, accessory: Element) : Section = section(mrkdwn(message), accessory)

/**
*  Generates a section block with a text object and an accessory element.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `Text` | The text object to use.
* | `accessory` | `Element` | The element to use.
* |===
*
* === Example
*
* This example generates a section with mrkdwn text and a simple button.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  section(mrkdwn("*Hello*"), button("Click me!", "bait"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "section",
*   "text": {
*     "type": "mrkdwn",
*     "text": "*Hello*"
*   },
*   "accessory": {
*     "type": "button",
*     "text": {
*       "type": "plain_text",
*       "text": "Click me!",
*       "emoji": true
*     },
*     "action_id": "bait"
*   }
* }
* ----
*/
fun section(text: Text, accessory : Element) : Section = {
    'type': "section",
    text: text,
    accessory: accessory
}

/**
*  Generates a section block with an array of text objects or fields.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `fields` | `Array<Text&#62;` | An array of text objects to use.
* |===
*
* === Example
*
* This example generates a section with mrkdwn text and plain text.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  section([mrkdwn("*Hello*"), text("Bye!")])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*    "type": "section",
*    "fields": [
*      {
*        "type": "mrkdwn",
*        "text": "*Hello*"
*      },
*      {
*        "type": "plain_text",
*        "text": "Bye!",
*        "emoji": true
*      }
*    ]
*  }
* ----
*/
fun section(fields: Array<Text>) : Section = {
    'type': "section",
    fields: fields
}

/**
*  Generates a section block with an array of text objects or fields, and an accessory element.
*
* https://api.slack.com/reference/block-kit/blocks#section[Section Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `fields` | `Array<Text&#62;` | An array of text objects to use.
* | `accessory` | `Element` | The element to use.
* |===
*
* === Example
*
* This example generates a section with mrkdwn text, plain text, and a simple button.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  section([mrkdwn("*Hello*"), text("Bye!")], button("Click me!", "bait"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "section",
*   "fields": [
*     {
*       "type": "mrkdwn",
*       "text": "*Hello*"
*     },
*     {
*       "type": "plain_text",
*       "text": "Bye!",
*       "emoji": true
*     }
*   ],
*   "accessory": {
*     "type": "button",
*     "text": {
*       "type": "plain_text",
*       "text": "Click me!",
*       "emoji": true
*     },
*     "action_id": "bait"
*   }
* }
* ----
*/
fun section(fields: Array<Text>, accessory : Element) : Section = {
    'type': "section",
    fields: fields,
    accessory: accessory
}

/**
*  Generates a header block with a simple plain text object.
*
* https://api.slack.com/reference/block-kit/blocks#header[Header Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired text.
* |===
*
* === Example
*
* This example generates a header with a simple text.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  header("Hello!")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "header",
*   "text": {
*     "type": "plain_text",
*     "text": "Hello!",
*     "emoji": true
*   }
* }
* ----
*/
fun header(message: String) : Header = header(text(message))

/**
*  Generates a header block with a plain text object.
*
* https://api.slack.com/reference/block-kit/blocks#header[Header Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `PlainText` | The plain text object to use.
* |===
*
* === Example
*
* This example generates a header with a plain text object with no support for emojis.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
* header({
*     'type': "plain_text",
*     text: "Hello!",
*     emojis: false
* })
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "header",
*   "text": {
*     "type": "plain_text",
*     "text": "Hello!",
*     "emoji": false
*   }
* }
* ----
*/
fun header(text: PlainText) : Header = {
    'type': "header",
    text: text
}

/**
*  Generates a button element with a simple plain text object and ID.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired text.
* | `id` | `String` | The value to use in an `action_id` field.
* |===
*
* === Example
*
* This example generates a button with simple text and an ID called "bait".
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  button("Click me!", "bait")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait"
* }
* ----
*/
fun button(message: String, id: String) : Button = button(text(message), id)

/**
*  Generates a button element with a plain text object and ID.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `PlainText` | The plain text object to use.
* | `id` | `String` | The value to use in an `action_id` field.
* |===
*
* === Example
*
* This example generates a button with text with an ID called "emoji".
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  button({'type': "plain_text", text: "Create your own :emoji:"}, "emoji")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Create your own :emoji:"
*   },
*   "action_id": "emoji"
* }
* ----
*/
fun button(text: PlainText, id: String) : Button = {
    'type': "button",
    text: text,
    action_id: id
}

/**
* Adds a value field to a button.
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `button` | `Button` | The button to add a value to.
* | `value` | `String` | The value to add.
* |===
*
* === Example
*
* This example shows how to use `withValue`.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* button("Click me!", "bait") withValue "spam"
*
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait",
*   "value": "spam"
* }
* ----
**/
fun withValue(button: Button, value: String) : Button = button mergeWith {value: value}

/**
* Adds a URL field to a button.
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `button` | `Button` | The button to add a value to.
* | `url` | `String` | The URL to add.
* |===
*
* === Example
*
* This example shows how to use `withUrl`.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* button("Click me!", "bait") withUrl "http://httpbin.org"
*
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait",
*   "url": "http://httpbin.org"
* }
* ----
**/
fun withUrl(button: Button, url: String) : Button = button mergeWith {url: url}

/**
* Adds a style field to a button.
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `button` | `Button` | The button to add a value to.
* | `style` | `Style` | The style to add.
* |===
*
* === Example
*
* This example shows how to use `withStyle`.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* button("Click me!", "bait") withStyle "danger"
*
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait",
*   "style": "danger"
* }
* ----
**/
fun withStyle(button: Button, style: Style) : Button = button mergeWith {style: style}

/**
*  Generates a button element with a simple plain text object, an ID, and a value.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `message` | `String` | The value to use in the desired text.
* | `id` | `String` | The value to use in an `action_id` field.
* | `value` | `String` | The value to use.
* |===
*
* === Example
*
* This example generates a button with a simple text, an ID called "bait", and a value.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  buttonWithValue("Click me!", "bait", "something to share")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait",
*   "value": "something to share"
* }
* ----
*/
fun buttonWithValue(message: String, id: String, value: String) : Button = buttonWithValue(text(message), id, value)

/**
*  Generates a button element with a plain text object, an ID, and a value.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `PlainText` | The value to use in the desired text.
* | `id` | `String` | The value to use in an `action_id` field.
* | `value` | `String` | The value to use. 
* |===
*
* === Example
*
* This example generates a button with text with an emoji, an ID called "emoji", and a value.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  buttonWithValue({'type': "plain_text", text: "Create your own :emoji:"}, "emoji", "origin")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Create your own :emoji:"
*   },
*   "action_id": "emoji",
*   "value": "origin"
* }
* ----
*/
fun buttonWithValue(text: PlainText, id: String, value: String) : Button = button(text, id) withValue value

/**
*  Generates a button element with a simple plain text object, an ID, and an URL.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired text.
* | `id` | `String` | The value to use in an `action_id` field.
* | `url` | `String` | The URL to use.
* |===
*
* === Example
*
* This example generates a button with simple text, an ID called "bait", and a URL to the Slack site.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  buttonWithUrl("Click me!", "bait", "https://slack.com")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Click me!",
*     "emoji": true
*   },
*   "action_id": "bait",
*   "url": "https://slack.com"
* }
* ----
*/
fun buttonWithUrl(message: String, id: String, url: String) : Button = buttonWithUrl(text(message), id, url)

/**
*  Generates a button element with a plain text object, an ID, and a URL.
*
* https://api.slack.com/reference/block-kit/block-elements#button[Button Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `text` | `PlainText` | The plain text object to use.
* | `id` | `String` | The value to use in an `action_id` field.
* | `url` | `String` | The URL to use.
* |===
*
* === Example
*
* This example generates a button with an emoji and text, an ID called "emoji", and a URL to the Slack site.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  buttonWithUrl({'type': "plain_text", text: "Create your own :emoji:"}, "emoji", "https://slack.com")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "button",
*   "text": {
*     "type": "plain_text",
*     "text": "Create your own :emoji:"
*   },
*   "action_id": "emoji",
*   "url": "https://slack.com"
* }
* ----
*/
fun buttonWithUrl(text: PlainText, id : String, url: String) : Button = button(text, id) withUrl url

/**
*  Generates an option object with a simple plain text
*  object and its value.
*
* https://api.slack.com/reference/block-kit/composition-objects#option[Option Object Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired text.
* | `value` | `String` | The value to use in the option.
* |===
*
* === Example
*
* This example generates multiple options from a list of strings, using the same text and value.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var versions = ["4.3.0", "4.2.2", "4.1.6"]
* ---
*  versions map ((item) -> option(item, item))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* [
*   {
*     "text": {
*       "type": "plain_text",
*       "text": "4.3.0",
*       "emoji": true
*     },
*     "value": "4.3.0"
*   },
*   {
*     "text": {
*       "type": "plain_text",
*       "text": "4.2.2",
*       "emoji": true
*     },
*     "value": "4.2.2"
*   },
*   {
*     "text": {
*       "type": "plain_text",
*       "text": "4.1.6",
*       "emoji": true
*     },
*     "value": "4.1.6"
*   }
* ]
* ----
*/
fun option(message: String, value: String) = option(text(message), value)

/**
*  Generates an option object with a text object and its value.
*
* https://api.slack.com/reference/block-kit/composition-objects#option[Option Object Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `text` | `Text` | The text to use.
* | `value` | `String` | The value to use in the option.
* |===
*
* === Example
*
* This example generates an option with mrkdwn text to select the color red. Its value references the hex
* color representation for red.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* ---
*  option(mrkdwn("*Red*"), "FF0000")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "text": {
*     "type": "mrkdwn",
*     "text": "*Red*"
*   },
*   "value": "FF0000"
* }
* ----
*/
fun option(text: Text, val: String) : Option = {
    text: text,
    value: val
}

/**
*  Generates an option group object with a simple plain text object and its options.
*
* https://api.slack.com/reference/block-kit/composition-objects#option_group[Option Group Object Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired text.
* | `options` | `Array<Option&#62;` | The options to group.
* |===
*
* === Example
*
* This example generates an option group with a simple value for some options.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var options = ["4.3.0", "4.2.2"] map ((item) -> option(item, item))
* ---
*  optionGroup("Recommended", options)
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "label": {
*     "type": "plain_text",
*     "text": "Recommended",
*     "emoji": true
*   },
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.3.0",
*         "emoji": true
*       },
*       "value": "4.3.0"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.2",
*         "emoji": true
*       },
*       "value": "4.2.2"
*     }
*   ]
* }
* ----
*/
fun optionGroup(message: String, options: Array<Option>) : OptionGroup = optionGroup(text(message), options)

/**
*  Generates an option group object with a plain text object and its options.
*
* https://api.slack.com/reference/block-kit/composition-objects#option_group[Option Group Object Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `text` | `PlainText` | The plain text to use.
* | `options` | `Array<Option&#62;` | The options to group.
* |===
*
* === Example
*
* This example generates an option group with text for some options.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var options = ["4.2.0", "4.2.1"] map ((item) -> option(item, item))
* ---
*  optionGroup({'type': "plain_text", text: "Others"}, options)
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "label": {
*     "type": "plain_text",
*     "text": "Others"
*   },
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.0",
*         "emoji": true
*       },
*       "value": "4.2.0"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.1",
*         "emoji": true
*       },
*       "value": "4.2.1"
*     }
*   ]
* }
* ----
*/
fun optionGroup(text : PlainText, options: Array<Option>) : OptionGroup = {
    label: text,
    options: options
}

/**
*  Generates a static select element with a simple plain text object as placeholder, its ID, and options.
*
* https://api.slack.com/reference/block-kit/block-elements#static_select[Static Options Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `message` | `String` | The value to use in the desired placeholder.
* | `id` | `String` | The value to use in an `action_id` field.
* | `options` | `Array<Option&#62;` | The array of options to offer.
* |===
*
* === Example
*
* This example creates a static group of options with a simple text placeholder.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var options = ["4.3.0", "4.2.2", "4.1.6"] map ((item) -> option(item, item))
* ---
*  staticSelect("Choose a version...", "version_menu", options)
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose a version...",
*     "emoji": true
*   },
*   "action_id": "version_menu",
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.3.0",
*         "emoji": true
*       },
*       "value": "4.3.0"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.2",
*         "emoji": true
*       },
*       "value": "4.2.2"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.1.6",
*         "emoji": true
*       },
*       "value": "4.1.6"
*     }
*   ]
* }
* ----
*/
fun staticSelect(placeholder: String, id: String, options: Array<Option>) : StaticSelect = staticSelect(text(placeholder), id, options)

/**
*  Generates a static select element with a simple plain text object as placeholder, its ID, and option groups.
*
* https://api.slack.com/reference/block-kit/block-elements#static_select[Static Options Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `message` | `String` | The value to use in the desired placeholder.
* | `id` | `String` | The value to use in an `action_id` field.
* | `optionGroups` | `Array<OptionGroup&#62;` | The array of options groups to offer.
* |===
*
* === Example
*
* This example creates a static group of option groups with a simple text placeholder.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var recommendedGroup = optionGroup("Recommended", [option("4.3.0", "latest")])
* var otherGroup = optionGroup("Other", [option("4.1.1", "original")])
* ---
*  staticSelectGrouped("Choose a version...", "version_menu", [recommendedGroup, otherGroup])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose a version...",
*     "emoji": true
*   },
*   "action_id": "version_menu",
*   "option_groups": [
*     {
*       "label": {
*         "type": "plain_text",
*         "text": "Recommended",
*         "emoji": true
*       },
*       "options": [
*         {
*           "text": {
*             "type": "plain_text",
*             "text": "4.3.0",
*             "emoji": true
*           },
*           "value": "latest"
*         }
*       ]
*     },
*     {
*       "label": {
*         "type": "plain_text",
*         "text": "Others",
*         "emoji": true
*       },
*       "options": [
*         {
*           "text": {
*             "type": "plain_text",
*             "text": "4.1.1",
*             "emoji": true
*           },
*           "value": "original"
*         }
*       ]
*     }
*   ]
* }
* ----
*/
fun staticSelectByGroups(placeholder: String, id: String, optionGroups: Array<OptionGroup>) : StaticSelect = staticSelectByGroups(text(placeholder), id, optionGroups)

/**
*  Generates an static select element with a simple plain text object as placeholder, its ID, and options.
*
* https://api.slack.com/reference/block-kit/block-elements#static_select[Static Options Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type  | Description
* | `message` | `String` | The value to use in the desired placeholder.
* | `id` | `String` | The value to use in an `action_id` field.
* | `options` | `Array<Option&#62;` | The array of options to offer.
* |===
*
* === Example
*
* This example creates a static group of options with a simple text placeholder.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var options = ["4.3.0", "4.2.2", "4.1.6"] map ((item) -> option(item, item))
* ---
*  staticSelect("Choose a version...", "version_menu", options)
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose a version...",
*     "emoji": true
*   },
*   "action_id": "version_menu",
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.3.0",
*         "emoji": true
*       },
*       "value": "4.3.0"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.2",
*         "emoji": true
*       },
*       "value": "4.2.2"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.1.6",
*         "emoji": true
*       },
*       "value": "4.1.6"
*     }
*   ]
* }
* ----
*/
fun staticSelect(placeholder: PlainText, id: String, options: Array<Option>) : StaticSelect = {
    'type': "static_select",
    placeholder: placeholder,
    action_id: id,
    options: options
}

/**
*  Generates an static select element with a plain text object as placeholder, its ID, and option groups.
*
* https://api.slack.com/reference/block-kit/block-elements#static_select[Static Options Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `text` | `PlainText` | The text to use as a placeholder.
* | `id` | `String` | The value to use in an `action_id` field.
* | `optionGroups` | `Array<OptionGroup&#62;` | The array of options groups to offer.
* |===
*
* === Example
*
* This example creates a static group of option groups with a text placeholder.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* import * from slack::Builders
* var recommendedGroup = optionGroup("Recommended", [option("4.3.0", "latest")])
* var otherGroup = optionGroup("Other", [option("4.1.1", "original")])
* ---
*  staticSelectByGroups({'type': "plain_text", text:"Some versions"}, "version_menu", [recommendedGroup, otherGroup])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Some versions"
*   },
*   "action_id": "version_menu",
*   "option_groups": [
*     {
*       "label": {
*         "type": "plain_text",
*         "text": "Recommended",
*         "emoji": true
*       },
*       "options": [
*         {
*           "text": {
*             "type": "plain_text",
*             "text": "4.3.0",
*             "emoji": true
*           },
*           "value": "latest"
*         }
*       ]
*     },
*     {
*       "label": {
*         "type": "plain_text",
*         "text": "Others",
*         "emoji": true
*       },
*       "options": [
*         {
*           "text": {
*             "type": "plain_text",
*             "text": "4.1.1",
*             "emoji": true
*           },
*           "value": "original"
*         }
*       ]
*     }
*   ]
* }
* ----
*/
fun staticSelectByGroups(placeholder: PlainText, id: String, optionGroups: Array<OptionGroup>) : StaticSelect = {
    'type': "static_select",
    placeholder: placeholder,
    action_id: id,
    'option_groups': optionGroups
}

/**
* Generates an external select element with a simple plain text object as placeholder and its ID.
*
* https://api.slack.com/reference/block-kit/block-elements#external_select[External Data Source Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `placeholder` | `String` | The value to use in the desired placeholder
* | `id` | `String` | The value to use in an `action_id` field.
* |===
*
* === Example
*
* This example shows how `externalSelect` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* externalSelect("Choose a dish", "dishes")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "external_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose a dish",
*     "emoji": true
*   },
*   "action_id": "dishes"
* }
* ----
**/
fun externalSelect(placeholder: String, id: String) : ExternalSelect = externalSelect(text(placeholder), id)

/**
* Generates an external select element with a text object as placeholder and its ID.
*
* https://api.slack.com/reference/block-kit/block-elements#external_select[External Data Source Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `placeholder` | `PlainText` | The text to use in the desired placeholder
* | `id` | `String` | The value to use in an `action_id` field.
* |===
*
* === Example
*
* This example shows how `externalSelect` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* externalSelect(text("Choose a dish"), "dishes")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "external_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose a dish",
*     "emoji": true
*   },
*   "action_id": "dishes"
* }
* ----
**/
fun externalSelect(placeholder: PlainText, id : String) : ExternalSelect = {
    "type" : "external_select",
    placeholder: placeholder,
    action_id: id
}

/**
* Generates an image element with its URL and alternative text.
*
* https://api.slack.com/reference/block-kit/block-elements#image[Image Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `url` | `String` | The URL to the image.
* | `text` | `String` | The text to use if the image cannot be rendered.
* |===
*
* === Example
*
* This example shows how `image` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* image("https://api.slack.com/img/blocks/bkb_template_images/profile_1.png", "Michael Scott")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "image",
*   "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png",
*   "alt_text": "Michael Scott"
* }
* ----
**/
fun image(url : String, text: String) : Image = {
    "type": "image",
    image_url: url,
    alt_text: text
}

/**
* Generates an image block with a simple text title.
*
* https://api.slack.com/reference/block-kit/blocks#image[Image Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `url` | `String` | The URL for the image.
* | `altText` | `String` | The alternative text for the image.
* | `title` | `String` | The value to use for the text title.
* |===
*
* === Example
*
* This example shows how `image` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* image("https://api.slack.com/img/blocks/bkb_template_images/profile_1.png", "profile pic", "Your new profile picture is saved")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "image",
*   "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png",
*   "alt_text": "profile pic",
*   "title": {
*     "type": "plain_text",
*     "text": "Your new profile picture is saved",
*     "emoji": true
*   }
* }
* ----
**/
fun image(url : String, altText: String, title: String) : ImageBlock = image(url, altText, text(title))

/**
* Generates an image block with a text title.
*
* https://api.slack.com/reference/block-kit/blocks#image[Image Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `url` | `String` | The URL for the image.
* | `altText` | `String` | The alternative text for the image.
* | `title` | `PlainText` | The text value to use as the title.
* |===
*
* === Example
*
* This example shows how `image` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* image("https://api.slack.com/img/blocks/bkb_template_images/profile_1.png", "profile pic", text("Your new profile picture is saved"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "image",
*   "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png",
*   "alt_text": "profile pic",
*   "title": {
*     "type": "plain_text",
*     "text": "Your new profile picture is saved",
*     "emoji": true
*   }
* }
* ----
**/
fun image(url : String, altText: String, title: PlainText) : ImageBlock = image(url, altText) mergeWith {title: title}

/**
* Generates a context block with a single plain text element item.
*
* https://api.slack.com/reference/block-kit/blocks#context[Context Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `message` | `String` | The value to use as text.
* |===
*
* === Example
*
* This example shows how `context` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* context(":calendar: Make sure to add this to your events")
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "context",
*   "elements": [
*     {
*       "type": "plain_text",
*       "text": ":calendar: Make sure to add this to your events",
*       "emoji": true
*     }
*   ]
* }
* ----
**/
fun context(message: String) : Context = context([text(message)])

/**
* Generates a context block with the desired elements.
*
* https://api.slack.com/reference/block-kit/blocks#context[Context Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name  | Type | Description
* | `elements` | `Array<Image&#124;Text&#62;` | The image or text elements.
* |===
*
* === Example
*
* This example shows how `context` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* context([mrkdwn("Built with :heart: by the DataWeave team")])
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "context",
*   "elements": [
*     {
*       "type": "mrkdwn",
*       "text": "Built with :heart: by the DataWeave team"
*     }
*   ]
* }
* ----
**/
fun context(elements: Array<Image|Text>) : Context = {
    "type": "context",
    elements: elements
}

/**
* Generates an input block with a simple text label.
*
* https://api.slack.com/reference/block-kit/blocks#input[Input Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `label` | `String` | The label for the input.
* | `element` | `Element` | The element to use in the input.
* |===
*
* === Example
*
* This example shows how `inputBlock` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* inputBlock("Please select your desired lunch:", inputText("lunch"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "input",
*   "label": {
*     "type": "plain_text",
*     "text": "Please select your desired lunch:",
*     "emoji": true
*   },
*   "element": {
*     "type": "plain_text_input",
*     "action_id": "lunch",
*     "multiline": false
*   }
* }
* ----
**/
fun inputBlock(label: String, element: Element) : Input = inputBlock(text(label), element)

/**
* Generates an input block.
*
* https://api.slack.com/reference/block-kit/blocks#input[Input Block Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type  | Description
* | `label` | `PlainText` | The label for the input.
* | `element` | `Element` | The element to use in the input.
* |===
*
* === Example
*
* This example shows how `inputBlock` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* inputBlock(text("Please select your desired lunch:"), inputText("lunch"))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "input",
*   "label": {
*     "type": "plain_text",
*     "text": "Please select your desired lunch:",
*     "emoji": true
*   },
*   "element": {
*     "type": "plain_text_input",
*     "action_id": "lunch",
*     "multiline": false
*   }
* }
* ----
**/
fun inputBlock(label: PlainText, element: Element) : Input = {
    "type": "input",
    label: label,
    element: element
}

/**
* Generates an input object.
*
* https://api.slack.com/reference/block-kit/block-elements#input[Plain-text Input Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `id` | `String` | The value to use in the `action_id` field.
* | `multiline` | `Boolean` | Whether the input should be multiline. Defaults to `false`.
* |===
*
* === Example
*
* This example shows how `inputText` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* inputText("suggestions", true)
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "plain_text_input",
*   "action_id": "suggestions",
*   "multiline": true
* }
* ----
**/
fun inputText(id: String, multiline: Boolean = false) : PlainTextInput = {
    "type": "plain_text_input",
    action_id: id,
    multiline: multiline
}

/**
* Generates a radio buttons group, given its ID and options.
*
* https://api.slack.com/reference/block-kit/block-elements#radio[Radio Button Group Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `id` | `String` | The value to use in the `action_id` field.
* | `options` | `Array<Option&#62;` | The options to group.
* |===
*
* === Example
*
* This example shows how `radioButtons` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* ---
* radioButtons("food", ["spaghetti", "fusilli", "orecchiette"] map option($, $))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "radio_buttons",
*   "action_id": "food",
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "spaghetti",
*         "emoji": true
*       },
*       "value": "spaghetti"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "fusilli",
*         "emoji": true
*       },
*       "value": "fusilli"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "orecchiette",
*         "emoji": true
*       },
*       "value": "orecchiette"
*     }
*   ]
* }
* ----
**/
fun radioButtons(id: String, options: Array<Option>) : RadioButtonGroup = {
    "type": "radio_buttons",
    action_id: id,
    options: options
}

/**
* Generates a multi-static select element with a simple text placeholder, ID, and options.
*
* https://api.slack.com/reference/block-kit/block-elements#multi_select[Multi-select Menu Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description
* | `placeholder` | `String` | The value to use in the desired placeholder.
* | `id` | `String` | The value to use in the `action_id` field.
* | `options` | `Array<Option&#62;` | The options to select.
* |===
*
* === Example
*
* This example shows how `multiStaticSelect` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* var versions = ["4.2.1", "4.2.2", "4.3.0"]
* ---
* multiStaticSelect("Choose versions...", "versions", versions map ((item, index) -> option(item, item)))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "multi_static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose versions...",
*     "emoji": true
*   },
*   "action_id": "versions",
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.1",
*         "emoji": true
*       },
*       "value": "4.2.1"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.2",
*         "emoji": true
*       },
*       "value": "4.2.2"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.3.0",
*         "emoji": true
*       },
*       "value": "4.3.0"
*     }
*   ]
* }
* ----
**/
fun multiStaticSelect(placeholder: String, id: String, options: Array<Option>) : MultiStaticSelect = multiStaticSelect(text(placeholder), id, options)

/**
* Generates a multi-static select element with its placeholder, ID, and options.
*
* https://api.slack.com/reference/block-kit/block-elements#multi_select[Multi-select Menu Element Reference]
*
* === Parameters
*
* [%header, cols="1,1,3"]
* |===
* | Name | Type | Description 
* | `placeholder` | `PlainText` | The text to use as a placeholder.
* | `id` | `String` | The value to use in the `action_id` field.
* | `options` | `Array<Option&#62;` | The options to select.
* |===
*
* === Example
*
* This example shows how `multiStaticSelect` behaves.
*
* ==== Source
*
* [source,DataWeave,linenums]
* ----
* %dw 2.0
* output application/json
* var versions = ["4.2.1", "4.2.2", "4.3.0"]
* ---
* multiStaticSelect(text("Choose versions..."), "versions", versions map ((item, index) -> option(item, item)))
* ----
*
* ==== Output
*
* [source,Json,linenums]
* ----
* {
*   "type": "multi_static_select",
*   "placeholder": {
*     "type": "plain_text",
*     "text": "Choose versions...",
*     "emoji": true
*   },
*   "action_id": "versions",
*   "options": [
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.1",
*         "emoji": true
*       },
*       "value": "4.2.1"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.2.2",
*         "emoji": true
*       },
*       "value": "4.2.2"
*     },
*     {
*       "text": {
*         "type": "plain_text",
*         "text": "4.3.0",
*         "emoji": true
*       },
*       "value": "4.3.0"
*     }
*   ]
* }
* ----
**/
fun multiStaticSelect(placeholder: PlainText, id: String, options: Array<Option>) : MultiStaticSelect = {
    "type": "multi_static_select",
    placeholder: placeholder,
    action_id: id,
    options: options
}

// ============================================================================================
//
//  EXTENSIONS  --  everything below was added to bring the original 2022 library up to the
//  current Slack Block Kit surface (https://docs.slack.dev/reference/block-kit). It adds:
//    1. Fluent modifiers (compose optional fields onto any block/element)
//    2. Composition-object builders (confirm, filter, dispatch config, slack_file, workflow)
//    3. Builders for elements that had types but no builder (checkboxes, pickers, overflow,
//       the remaining select/multi-select menus)
//    4. Builders for the missing/modern blocks (file, video, markdown)
//    5. Builders for the modern input elements (number/email/url/rich-text/file inputs,
//       datetimepicker, workflow_button)
//
//  Rich text (rich_text block) lives in slack::RichText. Surface wrappers (home/modal/message)
//  live in slack::Views. Limited-availability agentic blocks live in slack::Agentic.
//
// ============================================================================================

// --------------------------------------------------------------------------------------------
//  1. Fluent modifiers
//
//  These are intentionally loosely typed (Object -> Object) so they can be chained freely onto
//  any compatible block or element without fighting the type checker. Apply only fields the
//  target actually supports in Block Kit; Slack ignores or rejects unknown fields.
// --------------------------------------------------------------------------------------------

/** Adds a `block_id` to any block. */
fun withBlockId(block: Object, id: String) = block mergeWith {block_id: id}

/** Adds an `action_id` to any element. */
fun withActionId(element: Object, id: String) = element mergeWith {action_id: id}

/** Adds a `placeholder` (plain text) to an element that supports one. */
fun withPlaceholder(element: Object, message: String) = element mergeWith {placeholder: text(message)}

/** Adds a `confirm` dialog to an interactive element. */
fun withConfirm(element: Object, confirmation: Confirmation) = element mergeWith {confirm: confirmation}

/** Sets `focus_on_load` on an element that supports it. */
fun withFocus(element: Object, focus: Boolean = true) = element mergeWith {focus_on_load: focus}

/** Adds an `initial_option` to a select or radio group. */
fun withInitialOption(element: Object, initial: Option) = element mergeWith {initial_option: initial}

/** Adds `initial_options` to a multi-select or checkbox group. */
fun withInitialOptions(element: Object, initials: Array<Option>) = element mergeWith {initial_options: initials}

/** Adds a `hint` (plain text) to an input block. */
fun withHint(inputBlk: Object, message: String) = inputBlk mergeWith {hint: text(message)}

/** Marks an input block as optional (or required when `isOptional` is false). */
fun withOptional(inputBlk: Object, isOptional: Boolean = true) = inputBlk mergeWith {optional: isOptional}

/** Enables `dispatch_action` on an input block so it emits interactions as the user types. */
fun withDispatchAction(inputBlk: Object, dispatch: Boolean = true) = inputBlk mergeWith {dispatch_action: dispatch}

/** Attaches a `dispatch_action_config` to an input element. */
fun withDispatchActionConfig(element: Object, config: Dispatch) = element mergeWith {dispatch_action_config: config}

/** Adds an `accessibility_label` to a button or workflow button. */
fun withAccessibilityLabel(element: Object, label: String) = element mergeWith {accessibility_label: label}

/** Sets `emoji` on a plain-text object. */
fun withEmoji(txt: Object, emoji: Boolean) = txt mergeWith {emoji: emoji}

/** Sets `verbatim` on a mrkdwn object (disables auto-parsing of links/mentions). */
fun withVerbatim(txt: Object, verbatim: Boolean = true) = txt mergeWith {verbatim: verbatim}

/** Adds a `max_selected_items` cap to a multi-select menu. */
fun withMaxSelectedItems(element: Object, max: Number) = element mergeWith {max_selected_items: max}

// --------------------------------------------------------------------------------------------
//  2. Composition-object builders
// --------------------------------------------------------------------------------------------

/**
* Builds a plain-text object, letting you control the `emoji` flag (the `text` builder always
* sets `emoji: true`).
*/
fun plainText(message: String, emoji: Boolean) : PlainText = {
    'type': "plain_text",
    text: message,
    emoji: emoji
}

/**
* Builds a confirmation dialog object.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/confirmation-dialog-object
*/
fun confirm(title: String, message: String, confirmLabel: String, denyLabel: String) : Confirmation = {
    title: text(title),
    text: mrkdwn(message),
    confirm: text(confirmLabel),
    deny: text(denyLabel)
}

/**
* Builds an option object with a description sub-label.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/option-object
*/
fun optionWithDescription(message: String, val: String, description: String) : Option =
    option(message, val) mergeWith {description: text(description)}

/**
* Builds a dispatch-action configuration object.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/dispatch-action-configuration-object
*/
fun dispatchActionConfig(triggers: Array<DispatchOptions>) : Dispatch = {
    trigger_actions_on: triggers
}

/**
* Builds a conversation filter object for conversation select menus. Named `conversationFilter`
* (not `filter`) to avoid shadowing the DataWeave core `filter` function for consumers.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/conversation-filter-object
*/
fun conversationFilter(include: Array<FilterOptions>) : Filter = {
    include: include
}

/**
* Builds a Slack file object (an alternative image source to `image_url`), keyed by `id` or `url`.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/slack-file-object
*/
fun slackFile(idOrUrl: {id?: String, url?: String}) : SlackFile = idOrUrl

/**
* Builds a workflow object for use with `workflowButton`, from a trigger URL.
*
* https://docs.slack.dev/reference/block-kit/composition-objects/workflow-object
*/
fun workflow(triggerUrl: String) : Workflow = {
    trigger: {
        url: triggerUrl
    }
}

// --------------------------------------------------------------------------------------------
//  3. Builders for previously-typed-but-unbuilt elements
// --------------------------------------------------------------------------------------------

/**
* Builds a checkbox group element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/checkboxes-element
*/
fun checkboxes(id: String, options: Array<Option>) : Checkbox = {
    'type': "checkboxes",
    action_id: id,
    options: options
}

/**
* Builds an overflow menu element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/overflow-menu-element
*/
fun overflow(id: String, options: Array<Option>) : OverflowMenu = {
    'type': "overflow",
    action_id: id,
    options: options
}

/**
* Builds a date picker element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/date-picker-element
*/
fun datePicker(id: String) : DatePicker = {
    'type': "datepicker",
    action_id: id
}

/**
* Builds a time picker element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/time-picker-element
*/
fun timePicker(id: String, initialTime: String) : TimePicker = {
    'type': "timepicker",
    action_id: id,
    initial_time: initialTime
}

/**
* Builds a users select menu (single).
*
* https://docs.slack.dev/reference/block-kit/block-elements/multi-select-menu-element
*/
fun usersSelect(placeholder: String, id: String) : UserList = {
    'type': "users_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds a conversations select menu (single).
*/
fun conversationsSelect(placeholder: String, id: String) : ConversationsList = {
    'type': "conversations_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds a public-channels select menu (single).
*/
fun channelsSelect(placeholder: String, id: String) : PublicChannelsList = {
    'type': "channels_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds an external-data multi-select menu.
*/
fun multiExternalSelect(placeholder: String, id: String) : MultiExternalSelect = {
    'type': "multi_external_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds a users multi-select menu.
*/
fun multiUsersSelect(placeholder: String, id: String) : MultiUserList = {
    'type': "multi_users_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds a conversations multi-select menu.
*/
fun multiConversationsSelect(placeholder: String, id: String) : MultiConversationList = {
    'type': "multi_conversations_select",
    placeholder: text(placeholder),
    action_id: id
}

/**
* Builds a public-channels multi-select menu.
*/
fun multiChannelsSelect(placeholder: String, id: String) : MultiPublicChannelsList = {
    'type': "multi_channels_select",
    placeholder: text(placeholder),
    action_id: id
}

// --------------------------------------------------------------------------------------------
//  4. Builders for missing / modern blocks
// --------------------------------------------------------------------------------------------

/**
* Builds a file block referencing a remote file by external id.
*
* https://docs.slack.dev/reference/block-kit/blocks/file-block
*/
fun file(externalId: String) : File = {
    'type': "file",
    external_id: externalId,
    source: "remote"
}

/**
* Builds a `markdown` block: the full GitHub-flavored-markdown block, purpose-built for rendering
* an LLM/agent's markdown response. Unlike a `section` with a `mrkdwn` text object, this renders
* headings, tables, task lists, nested lists, block quotes, horizontal rules, and fenced code
* blocks with syntax highlighting.
*
* Pass the raw markdown string straight through -- do NOT pre-convert it to Slack `mrkdwn`. The
* combined `text` across all markdown blocks in a payload is capped at 12,000 characters, and
* `block_id` is ignored by Slack on this block type.
*
* [source,DataWeave]
* ----
* markdownBlock("## Summary\n\n| Metric | Value |\n|---|---|\n| Uptime | 99.9% |\n\n- [x] done\n- [ ] todo")
* ----
*
* https://docs.slack.dev/reference/block-kit/blocks/markdown-block
*/
fun markdownBlock(markdownText: String) : MarkdownBlock = {
    'type': "markdown",
    text: markdownText
}

/**
* Builds a video block. `title` and `alt_text` are required by Slack.
*
* https://docs.slack.dev/reference/block-kit/blocks/video-block
*/
fun videoBlock(videoUrl: String, thumbnailUrl: String, altText: String, title: String) : VideoBlock = {
    'type': "video",
    video_url: videoUrl,
    thumbnail_url: thumbnailUrl,
    alt_text: altText,
    title: text(title)
}

// --------------------------------------------------------------------------------------------
//  5. Builders for modern input elements
// --------------------------------------------------------------------------------------------

/**
* Builds a datetime picker element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/datetime-picker-element
*/
fun datetimePicker(id: String) : DatetimePicker = {
    'type': "datetimepicker",
    action_id: id
}

/**
* Builds a number input element. `isDecimalAllowed` is required by Slack.
*
* https://docs.slack.dev/reference/block-kit/block-elements/number-input-element
*/
fun numberInput(id: String, isDecimalAllowed: Boolean = false) : NumberInput = {
    'type': "number_input",
    is_decimal_allowed: isDecimalAllowed,
    action_id: id
}

/**
* Builds an email input element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/email-input-element
*/
fun emailInput(id: String) : EmailInput = {
    'type': "email_text_input",
    action_id: id
}

/**
* Builds a URL input element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/url-input-element
*/
fun urlInput(id: String) : UrlInput = {
    'type': "url_text_input",
    action_id: id
}

/**
* Builds a rich text input element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/rich-text-input-element
*/
fun richTextInput(id: String) : RichTextInput = {
    'type': "rich_text_input",
    action_id: id
}

/**
* Builds a file input element.
*
* https://docs.slack.dev/reference/block-kit/block-elements/file-input-element
*/
fun fileInput(id: String) : FileInput = {
    'type': "file_input",
    action_id: id
}

/**
* Builds a workflow button element from a display label, a trigger URL, and an action id.
*
* https://docs.slack.dev/reference/block-kit/block-elements/workflow-button-element
*/
fun workflowButton(message: String, triggerUrl: String, id: String) : WorkflowButton = {
    'type': "workflow_button",
    text: text(message),
    workflow: workflow(triggerUrl),
    action_id: id
}
