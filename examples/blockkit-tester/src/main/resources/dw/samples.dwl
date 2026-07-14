/**
* Catalog of Block Kit sample payloads, each built with the dataweave-slack-blockkit library.
* `messages` are chat.postMessage-compatible block arrays; `homeBlocks` targets views.publish.
* Keep this file ASCII-only (emoji as :shortcodes:) to match the library's charset guidance.
*/
%dw 2.0
import * from slack::Builders
import * from slack::RichText
import * from slack::Guards

// A long string (> 3000 chars) to exercise the section splitter.
var longText = (1 to 140) map ((i) -> "Paragraph $(i): the quick brown fox jumps over the lazy dog.") joinBy "\n\n"

/**
* Message samples: keyed block arrays valid inside a chat.postMessage payload.
* (Input blocks are intentionally excluded -- they only render in modals / App Home.)
*/
var messages = {
    "section-mrkdwn": [
        section("*Hello* from _Block Kit_ :wave:  `dataweave-slack-blockkit`")
    ],
    "section-fields": [
        section([ mrkdwn("*Environment*\nProduction"), mrkdwn("*Status*\n:large_green_circle: Healthy") ])
    ],
    "section-accessory": [
        section("Tim's farewell party is tonight at 8 PM", button("RSVP", "rsvp") withStyle "primary" withValue "yes")
    ],
    "header": [
        header("Deployment Report")
    ],
    "divider": [
        section("Above the line"), divider(), section("Below the line")
    ],
    "actions-buttons": [
        actions([
            button("Approve", "approve") withStyle "primary" withValue "42",
            button("Reject", "reject") withStyle "danger" withValue "42",
            buttonWithUrl("Open docs", "docs", "https://docs.slack.dev")
        ])
    ],
    "actions-menus": [
        actions([
            staticSelect("Choose a level", "log_level", [ option("INFO", "INFO"), option("WARN", "WARN"), option("ERROR", "ERROR") ]),
            overflow("more", [ option("Edit", "edit"), option("Delete", "delete") ]),
            datePicker("pick_date")
        ])
    ],
    "context": [
        context([ image("https://api.slack.com/img/blocks/bkb_template_images/profile_1.png", "author"), mrkdwn("Posted by *Block Kit Tester* just now") ])
    ],
    "image": [
        image("https://api.slack.com/img/blocks/bkb_template_images/beagle.png", "a cute beagle", "Please enjoy this photo of a beagle")
    ],
    "rich-text": [
        richText([
            rtSection([ rtText("Rich text with "), rtText("bold", { bold: true }), rtText(", "), rtText("italics", { italic: true }), rtText(", and a "), rtLink("https://slack.com", "link"), rtText(".") ]),
            rtBulletList([ rtSection([ rtText("first bullet") ]), rtSection([ rtText("second bullet") ]) ]),
            rtQuote([ rtText("A wise quote.") ]),
            rtPreformatted([ rtText("payload map (x) -> x * 2") ])
        ])
    ],
    "markdown-block": [
        markdownBlock("## Full Markdown Block\n\nRenders GitHub-flavored markdown that `mrkdwn` cannot:\n\n| Metric | Value |\n|--------|-------|\n| Uptime | 99.9% |\n| Errors | 0 |\n\n- [x] tables\n- [x] task lists\n- [ ] world domination\n\n```dataweave\n1 + 1\n```")
    ],
    "guards-section-split": sectionBlocks(longText, "split"),
    "guards-field-split": fieldSections((1 to 14) map ((i) -> "*Field $(i)*\nvalue $(i)"), "split"),
    "guards-actions-split": actionsBlocks((1 to 30) map ((i) -> button("Button $(i)", "action_$(i)")), "split")
}

/** App Home surface sample (includes an input block, valid only on modals / App Home). */
var homeBlocks = [
    header("Block Kit Tester :test_tube:"),
    section("This App Home view was published by the tester app."),
    divider(),
    inputBlock("Your name", inputText("name_input")),
    actions([ button("Say hi", "say_hi") withStyle "primary" ])
]
