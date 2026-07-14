/**
* Test suite for the DataWeave Slack Block Kit library. Exercises a representative builder from
* every module so that `mvn test` both type-checks all sources and asserts their JSON output.
*/
%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from slack::Builders
import * from slack::RichText
import * from slack::Views
import * from slack::Agentic
import * from slack::Guards
---
"DataWeave Slack Block Kit" describedBy [

    // ---- core builders (backward compatibility) ----------------------------------------
    "divider() builds a divider block" in do {
        divider() must equalTo({ "type": "divider" })
    },
    "section(String) wraps mrkdwn" in do {
        section("Hello!") must equalTo({ "type": "section", text: { "type": "mrkdwn", text: "Hello!" } })
    },
    "button with style and value composes" in do {
        (button("Save", "save_id") withStyle "primary" withValue "v1") must equalTo({
            "type": "button",
            text: { "type": "plain_text", text: "Save", emoji: true },
            action_id: "save_id",
            style: "primary",
            value: "v1"
        })
    },

    // ---- new fluent modifiers -----------------------------------------------------------
    "withBlockId adds a block_id" in do {
        (divider() withBlockId "d1") must equalTo({ "type": "divider", block_id: "d1" })
    },
    "confirm builds a confirmation dialog" in do {
        confirm("Sure?", "This cannot be undone", "Yes", "No") must equalTo({
            title: { "type": "plain_text", text: "Sure?", emoji: true },
            text: { "type": "mrkdwn", text: "This cannot be undone" },
            confirm: { "type": "plain_text", text: "Yes", emoji: true },
            deny: { "type": "plain_text", text: "No", emoji: true }
        })
    },

    // ---- new element builders over existing types ---------------------------------------
    "checkboxes builds a checkbox group" in do {
        checkboxes("cb", [option("A", "a")]) must equalTo({
            "type": "checkboxes",
            action_id: "cb",
            options: [ { text: { "type": "plain_text", text: "A", emoji: true }, value: "a" } ]
        })
    },
    "usersSelect builds a users_select" in do {
        usersSelect("Pick a user", "us") must equalTo({
            "type": "users_select",
            placeholder: { "type": "plain_text", text: "Pick a user", emoji: true },
            action_id: "us"
        })
    },
    "datePicker builds a datepicker" in do {
        datePicker("dp") must equalTo({ "type": "datepicker", action_id: "dp" })
    },

    // ---- modern blocks / inputs ---------------------------------------------------------
    "markdownBlock builds a markdown block" in do {
        markdownBlock("*hi*") must equalTo({ "type": "markdown", text: "*hi*" })
    },
    "markdownBlock passes full GFM (headings/tables/tasks) through verbatim" in do {
        markdownBlock("## H\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\n- [x] done") must equalTo({
            "type": "markdown",
            text: "## H\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\n- [x] done"
        })
    },
    "markdownMessage wraps a markdown block into a message payload" in do {
        (markdownMessage("# Report") withChannel "C1") must equalTo({
            blocks: [ { "type": "markdown", text: "# Report" } ],
            channel: "C1"
        })
    },
    "numberInput requires is_decimal_allowed" in do {
        numberInput("n", true) must equalTo({ "type": "number_input", is_decimal_allowed: true, action_id: "n" })
    },
    "workflowButton nests a workflow trigger" in do {
        workflowButton("Run", "https://trigger", "wf") must equalTo({
            "type": "workflow_button",
            text: { "type": "plain_text", text: "Run", emoji: true },
            workflow: { trigger: { url: "https://trigger" } },
            action_id: "wf"
        })
    },

    // ---- rich text ----------------------------------------------------------------------
    "richText composes sections and inline elements" in do {
        richText([ rtSection([ rtText("Hi "), rtUser("U1") ]) ]) must equalTo({
            "type": "rich_text",
            elements: [
                { "type": "rich_text_section", elements: [
                    { "type": "text", text: "Hi " },
                    { "type": "user", user_id: "U1" }
                ] }
            ]
        })
    },
    "rtText with style attaches style object" in do {
        rtText("bold", { bold: true }) must equalTo({ "type": "text", text: "bold", style: { bold: true } })
    },

    // ---- views / surfaces ---------------------------------------------------------------
    "publishHomeView wraps a home view payload" in do {
        publishHomeView("U9", [ section("hi") ]) must equalTo({
            user_id: "U9",
            view: { "type": "home", blocks: [ { "type": "section", text: { "type": "mrkdwn", text: "hi" } } ] }
        })
    },
    "modalView with submit" in do {
        (modalView("Title", []) withSubmit "Go") must equalTo({
            "type": "modal",
            title: { "type": "plain_text", text: "Title", emoji: true },
            blocks: [],
            submit: { "type": "plain_text", text: "Go", emoji: true }
        })
    },

    // ---- agentic (experimental) ---------------------------------------------------------
    "alert builds an alert block" in do {
        alert("Heads up", "warning") must equalTo({ "type": "alert", text: { "type": "mrkdwn", text: "Heads up" }, level: "warning" })
    },
    "taskCard with reserved-word output field" in do {
        (taskCard("t1", "Doing", "in_progress") withTaskOutput { "type": "rich_text", elements: [] }) must equalTo({
            "type": "task_card",
            task_id: "t1",
            title: "Doing",
            status: "in_progress",
            "output": { "type": "rich_text", elements: [] }
        })
    },
    "table with raw cells" in do {
        table([[ rawText("A"), rawText("B") ]]) must equalTo({
            "type": "table",
            rows: [[ { "type": "raw_text", text: "A" }, { "type": "raw_text", text: "B" } ]]
        })
    },

    // ---- guardrails ---------------------------------------------------------------------
    "chunkText splits on paragraph boundary within the limit" in do {
        chunkText("aaaa\n\nbbbb", 5) must equalTo([ "aaaa", "bbbb" ])
    },
    "chunkText falls through to lines, then words, then hard cut" in do {
        chunkText("abcdefghij", 4) must equalTo([ "abcd", "efgh", "ij" ])
    },
    "truncateText cuts within budget and appends ellipsis" in do {
        truncateText("hello world", 8) must equalTo("hello...")
    },
    "sectionBlocks returns a single section when under the limit" in do {
        sectionBlocks("short", "split") must equalTo([
            { "type": "section", text: { "type": "mrkdwn", text: "short" } }
        ])
    },
    "markdownMessages returns one message payload when under the limit" in do {
        markdownMessages("# ok") must equalTo([ { blocks: [ { "type": "markdown", text: "# ok" } ] } ])
    },
    "safeHeader truncates an over-long title to 150 chars" in do {
        sizeOf((safeHeader((1 to 200) map "x" joinBy "")).text.text) must equalTo(150)
    },
    "paginateBlocks splits a block list across pages" in do {
        paginateBlocks([1, 2, 3, 4, 5], 2) must equalTo([ [1, 2], [3, 4], [5] ])
    },
    "chunkArray groups items by size" in do {
        chunkArray(["a", "b", "c"], 2) must equalTo([ ["a", "b"], ["c"] ])
    },
    "fieldSections spills fields beyond 10 into a second section" in do {
        sizeOf(fieldSections((1 to 12) map ((i) -> "field $(i)"), "split")) must equalTo(2)
    },
    "fieldSections keeps <=10 fields in a single section" in do {
        fieldSections(["A", "B"], "split") must equalTo([
            { "type": "section", fields: [ { "type": "mrkdwn", text: "A" }, { "type": "mrkdwn", text: "B" } ] }
        ])
    },
    "contextBlocks splits elements beyond 10 across blocks" in do {
        sizeOf(contextBlocks((1 to 23) map ((i) -> mrkdwn("e$(i)")), "split")) must equalTo(3)
    },
    "actionsBlocks splits elements beyond 25 across blocks" in do {
        sizeOf(actionsBlocks((1 to 60) map ((i) -> button("b$(i)", "a$(i)")), "split")) must equalTo(3)
    },
    "actionsBlocks keeps a small element set in one block" in do {
        actionsBlocks([ button("Go", "go") ], "split") must equalTo([
            { "type": "actions", elements: [ { "type": "button", text: { "type": "plain_text", text: "Go", emoji: true }, action_id: "go" } ] }
        ])
    }
]
