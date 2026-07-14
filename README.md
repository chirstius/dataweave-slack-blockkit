# DataWeave Slack Block Kit

[![CI](https://github.com/chirstius/dataweave-slack-blockkit/actions/workflows/ci.yml/badge.svg)](https://github.com/chirstius/dataweave-slack-blockkit/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/chirstius/dataweave-slack-blockkit?sort=semver)](https://github.com/chirstius/dataweave-slack-blockkit/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

A DataWeave library of builder functions and types for composing
[Slack Block Kit](https://docs.slack.dev/reference/block-kit) payloads from MuleSoft (Mule 4)
applications — layout blocks, interactive elements, composition objects, rich text, surfaces
(App Home / modals / messages), and Slack's newer "agentic" / AI-app blocks.

It began as a modernization of MuleSoft's original *Slack Block Kit for DataWeave* library
(circa 2022) and brings it up to the current Block Kit surface, while remaining **backward
compatible** — existing code that does `import * from slack::Builders` keeps working unchanged.

- **Zero runtime dependencies.** The artifact is just `.dwl` source under `slack/`; it runs on
  any Mule 4.x runtime that imports it.
- **Backward compatible.** Every function and type from the original library is preserved.
- **Type-checked & tested.** All modules compile against the DataWeave type checker and ship
  with a passing test suite.

## Installation

Pick whichever fits your project. All three are credential-free and independent of any Anypoint
organization.

### 1. Maven (recommended)

Add the dependency (published to Maven Central — a default Maven repository, so no extra
`<repository>` block is needed):

```xml
<dependency>
  <groupId>io.github.chirstius</groupId>
  <artifactId>dataweave-slack-blockkit</artifactId>
  <version>1.0.0</version>
</dependency>
```

> A `-dw-library`-classified jar with identical content is also published, if you prefer the
> MuleSoft convention — add `<classifier>dw-library</classifier>`. Both resolve the same
> `slack::*` modules.

### 2. JitPack (build straight from a GitHub tag)

```xml
<repositories>
  <repository>
    <id>jitpack.io</id>
    <url>https://jitpack.io</url>
  </repository>
</repositories>

<dependency>
  <groupId>com.github.chirstius</groupId>
  <artifactId>dataweave-slack-blockkit</artifactId>
  <version>v1.0.0</version>
</dependency>
```

### 3. Copy-in (no Maven at all)

Copy the files under [`src/main/dw/slack`](src/main/dw/slack) into your app's
`src/main/resources/dw/slack/` directory. The `slack::*` imports resolve the same way.

## Quick start

```dataweave
%dw 2.0
output application/json
import * from slack::Builders
import * from slack::RichText
import * from slack::Views
---
publishHomeView("U0123", [
  header("Welcome :wave:"),
  section("*Here's what's new*"),
  divider(),
  richText([
    rtSection([ rtText("Ping "), rtUser("U9999"), rtText(" for help.") ]),
    rtBulletList([
      rtSection([ rtText("Fast") ]),
      rtSection([ rtText("Composable") ])
    ])
  ]),
  actions([
    button("Get started", "start") withStyle "primary" withValue "go",
    button("Docs", "docs") withUrl "https://docs.slack.dev"
  ])
])
```

## Modules

Import only what you need. Each is a separate DataWeave module under the `slack` namespace.

| Import | What it provides |
|---|---|
| `slack::Builders` | Core builders: blocks (section, header, actions, context, divider, image, input, file, video, markdown), interactive elements (buttons, selects, multi-selects, checkboxes, radio, overflow, date/time/datetime pickers, modern inputs, workflow button), composition objects (text, mrkdwn, option, option group, confirm, filter, dispatch config, slack file, workflow), and fluent modifiers (`withBlockId`, `withStyle`, `withValue`, `withUrl`, `withConfirm`, `withPlaceholder`, `withInitialOption`, `withHint`, `withOptional`, ...). Re-imports the `Blocks` / `Elements` / `Objects` types. |
| `slack::RichText` | The `rich_text` block, its four sub-blocks (section, list, quote, preformatted), and inline elements (text with styles, user / channel / usergroup mentions, emoji, link, date, broadcast, color). |
| `slack::Views` | Surface wrappers — `homeView`, `modalView`, `message` — plus API request envelopes (`publishHomeView`, `openView`, `updateView`) and message modifiers (`withChannel`, `withThreadTs`, `withText`, ...). |
| `slack::Agentic` | **Experimental / limited availability.** Newer AI-app blocks: `card`, `carousel`, `container`, `context_actions`, `table`, `data_table`, `data_visualization`, `alert`, `plan`, `task_card`, and the `feedback_buttons` / `icon_button` / `url_source` elements. Includes a generic `agenticBlock(type, fields)` escape hatch for schema churn. |
| `slack::Guards` | Guardrails for Slack's content limits with a per-call policy (`"error"` / `"truncate"` / `"split"`): a smart text splitter (`chunkText`), `sectionBlocks` (3,000/section), `markdownMessages` (12,000 cumulative → paginate across messages), `safeHeader` / `safeButton`, `paginateBlocks` / `assertBlockCount`, plus the limit constants. |
| `slack::Blocks`, `slack::Elements`, `slack::Objects` | The underlying `type` definitions, if you want to annotate your own functions. |

### Rendering agent / LLM responses

To render a full markdown response from an LLM, use the **`markdown` block** (`markdownBlock` /
`markdownMessage`) — *not* a section with a `mrkdwn` text object. The markdown block renders
GitHub-flavored markdown (headings, tables, task lists, nested lists, block quotes, horizontal
rules, and fenced code blocks with syntax highlighting); `mrkdwn` supports none of those. Pass the
raw markdown straight through:

```dataweave
%dw 2.0
output application/json
import * from slack::Builders
import * from slack::Views
---
markdownMessage(payload.agentReply) withChannel vars.channel withThreadTs vars.threadTs
```

`text` is capped at 12,000 characters cumulatively across all markdown blocks in a payload — see
Guardrails below for handling responses that exceed it.

## Guardrails for content limits

Slack rejects an entire payload if any field exceeds its limit — easy to trip when content comes
from an LLM, a database, or user input. `slack::Guards` lets you choose, per call, what happens on
overflow via a policy parameter:

- `"error"` — fail fast with a clear message (default for single-line fields like headers/buttons)
- `"truncate"` — cut to the limit on a word boundary, append an ellipsis
- `"split"` — smartly split across multiple blocks/messages (default where splitting is valid)

The splitter breaks on the coarsest boundary that fits — paragraphs, then lines, then spaces, and
only hard-cuts mid-token as a last resort — so markdown structure (headings, tables, code fences)
survives.

Crucially, it respects **which kind** of limit each field has:

```dataweave
%dw 2.0
output application/json
import * from slack::Builders
import * from slack::Views
import * from slack::Guards
---
// section text is a PER-BLOCK 3,000 limit -> split into multiple sections
{ blocks: sectionBlocks(payload.longText, "split") }

// markdown block text is a 12,000 CUMULATIVE-per-payload limit -> paginate across messages,
// each a full-markdown message you post in sequence / in-thread
markdownMessages(payload.agentReply, "split")
  map ($ withChannel vars.channel withThreadTs vars.threadTs)
```

The same policy applies to **count-based** limits:

- `fieldSections(fields, policy)` — guards both the per-field 2,000-char limit and the
  10-fields-per-section limit, spilling extra fields into more section blocks
- `contextBlocks(elements, policy)` — 10 elements per context block
- `actionsBlocks(elements, policy)` — 25 elements per actions block

Other helpers: `safeHeader` / `safeButton` (truncate or error on single-line limits),
`paginateBlocks` (split a big block list across the 50-block message limit), `chunkArray` /
`chunkText` / `truncateText` (raw utilities), `assertBlockCount` (fail-fast final check), and the
limit constants (`SECTION_TEXT_MAX_LENGTH`, `SECTION_FIELD_MAX_LENGTH`, `SECTION_FIELDS_MAX`,
`MARKDOWN_MAX_LENGTH`, `HEADER_MAX_LENGTH`, `CONTEXT_ELEMENTS_MAX`, `ACTIONS_ELEMENTS_MAX`,
`MESSAGE_MAX_BLOCKS`, …).

> The `slack::Agentic` blocks are not generally available in every workspace or on every surface
> (e.g. alert blocks are modal-only). Their schemas can change upstream; the module is kept
> separate so the stable core stays clean.

## Backward compatibility

This library is a strict superset of the original `data-weave-slack-library` 1.0.0. Drop-in
replacement: swap the dependency coordinates and keep your existing `import * from slack::Builders`
code as-is. All original builder signatures and type names are unchanged.

## Building and testing

Requires Maven and a JDK. The build uses the DataWeave Maven plugin (resolved from MuleSoft's
public repository — no credentials).

```bash
mvn clean test      # compile all modules + run the DataWeave test suite
mvn clean package    # produce the dw-library jar in target/
```

Tests live in [`src/test/dw`](src/test/dw) and assert builder output against expected Block Kit
JSON.

### Publishing a release

`mvn -Prelease deploy` signs the artifacts (GPG) and publishes to the Sonatype Central Portal.
Requires a `central` server entry in `settings.xml` and a GPG signing key.

## License

[Apache License 2.0](LICENSE).

Not affiliated with or endorsed by Slack Technologies. "Slack" and "Block Kit" are trademarks of
Slack Technologies, LLC.
