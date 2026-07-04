# voicedit

Acting on what's in front of you - "summarize this thread", "draft a reply",
"what was decided?" - needs one thing before voice or an LLM can help: the
context of what's on your screen. `ve` is that primitive. It dumps the frontmost
application's accessibility tree as JSON, so anything above it (an adapter, a
summarizer, a voice assistant) can read the screen without knowing how.

`ve` is the perception layer, built and shipped on its own. It follows the
[Unix philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) - do one thing
well and compose with other tools rather than absorbing their jobs. See
[docs/adr](docs/adr) for the decisions behind the split.

## Install

```
brew install mmurakaru/tap/ve
```

## Build from source

```
swift build
```

## Run

```
swift run ve            # frontmost application
swift run ve --pid 1234 # a specific process
```

Requires Accessibility permission (System Settings > Privacy & Security >
Accessibility). On first run without it, `ve` prints setup instructions to
stderr and exits non-zero.

## Adapters

`ve` has no app awareness. Interpreting its output for a specific app is the
job of a disposable adapter that consumes it. `adapters/slack-adapter` is an
example: it shells out to `ve` and filters the result down to Slack message
text. Adapters are allowed to be sloppy and are not part of the primitive.

```
swift build
Slack frontmost, then: adapters/slack-adapter
```

## Test

```
swift test
python3 adapters/slack-adapter-test
```
