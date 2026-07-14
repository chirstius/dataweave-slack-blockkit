# Slack Block Kit Tester

A small Mule 4 app that renders every builder in
[`dataweave-slack-blockkit`](../../README.md) and posts the payloads to the **real Slack Web
API**, so you can confirm Slack accepts them (`ok: true`) and see Slack's own block-validation
messages when something is off.

## How credentials are handled

**The app stores no token.** You supply a Slack bot or user token **per request** via the
`Authorization: Bearer <token>` header; the app forwards it to Slack and nothing is persisted.
Keep the token in an environment variable so it never lands in shell history:

```bash
export SLACK_TOKEN="xoxb-your-bot-token"      # bot token (chat:write, and for /home: none extra)
export SLACK_CHANNEL="C0123456789"            # a channel your bot is a member of
```

Required Slack scopes: `chat:write` (send), and the bot must be invited to the target channel.
For `/home`, the App Home tab must be enabled for your app.

## Run it

Build the library first (once), then this app:

```bash
# from the repo root
mvn -f ../../pom.xml install -DskipTests     # publishes the library to your local ~/.m2
mvn install                                   # from examples/blockkit-tester
```

Deploy the resulting `target/blockkit-tester-1.0.0-mule-application.jar` to a local Mule 4.10
runtime (or run it from Anypoint Studio). The app listens on `http://localhost:8081`.

## Web UI (easiest)

Open **`http://localhost:8081/`** in a browser. You get a small control panel:

- Enter your Slack **token**, **channel ID**, and (for App Home) **user ID**.
- Pick a sample and **Preview JSON** (no token) or **Send to Slack**.
- **Send all message samples** or **Publish App Home** in one click.
- Each result shows a pass/fail badge plus Slack's raw response (and `blockErrors` when Slack
  rejects a payload).

The token is used only to make the request from the app to Slack; it is never stored. The
endpoints below back the UI and are equally usable directly.

## Endpoints

| Method & path | What it does | Needs token? |
|---|---|---|
| `GET /samples` | Lists sample keys and returns the rendered JSON for every message sample (dry run) | No |
| `GET /samples/{key}` | Returns the rendered JSON for one sample (dry run) | No |
| `POST /send/{key}?channel=C…` | Posts one sample to Slack, returns Slack's verdict | Yes |
| `POST /send-all?channel=C…` | Posts every message sample, returns a pass/fail summary | Yes |
| `POST /home?user=U…` | Publishes the App Home sample (input block + actions) via `views.publish` | Yes |

Sample keys: `section-mrkdwn`, `section-fields`, `section-accessory`, `header`, `divider`,
`actions-buttons`, `actions-menus`, `context`, `image`, `rich-text`, `markdown-block`,
`guards-section-split`.

## Examples

Dry run — no token, just eyeball the JSON (or paste into Slack's Block Kit Builder):

```bash
curl -s localhost:8081/samples | jq '.messageSamples'
curl -s localhost:8081/samples/markdown-block | jq
```

Send one sample and read Slack's verdict:

```bash
curl -s -X POST "localhost:8081/send/rich-text?channel=$SLACK_CHANNEL" \
  -H "Authorization: Bearer $SLACK_TOKEN" | jq '{valid, slackError, blockErrors}'
```

Run the whole suite and get a summary:

```bash
curl -s -X POST "localhost:8081/send-all?channel=$SLACK_CHANNEL" \
  -H "Authorization: Bearer $SLACK_TOKEN" | jq '{total, passed, failed, results: [.results[] | {sample, valid, slackError}]}'
```

Publish the App Home sample:

```bash
curl -s -X POST "localhost:8081/home?user=U0123456789" \
  -H "Authorization: Bearer $SLACK_TOKEN" | jq '{valid, slackError, blockErrors}'
```

## Reading the result

- `valid: true` — Slack accepted the payload; the library emitted valid Block Kit.
- `valid: false` with `slackError: "invalid_blocks"` and a populated `blockErrors` array — Slack
  rejected it; `blockErrors` contains Slack's exact per-block validation messages.
- `slackError: "invalid_auth" / "not_authed"` — token problem, not a Block Kit problem.
- `slackError: "channel_not_found" / "not_in_channel"` — invite the bot to the channel.
