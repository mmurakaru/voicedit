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
swift run read
```

Requires Accessibility permission (System Settings > Privacy & Security >
Accessibility). On first run without it, `read` prints setup instructions to
stderr and exits non-zero.

## Test

```
swift test
```
