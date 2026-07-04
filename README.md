# voicedit

`read` is a macOS CLI that dumps the frontmost application's accessibility
tree as JSON - the primitive, not a product. See
[the PRD](https://www.amplifypartners.com/blog-posts/the-primitive-is-the-product)
for the philosophy behind the split.

## Build

```
swift build
```

## Run

```
swift run read            # frontmost application
swift run read --pid 1234 # a specific process
```

Requires Accessibility permission (System Settings > Privacy & Security >
Accessibility). On first run without it, `read` prints setup instructions to
stderr and exits non-zero.

## Adapters

`read` has no app awareness. Interpreting its output for a specific app is the
job of a disposable adapter that consumes it. `adapters/slack-adapter` is an
example: it shells out to `read` and filters the result down to Slack message
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
