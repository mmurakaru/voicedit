# 2. Text extraction is generic, not app-aware

Status: accepted

## Context

The first cut of `ve` collected `AXStaticText` nodes plus any node with a
non-empty `kAXValueAttribute`. Run against Calculator, that captured only the
two display labels and missed all 25 buttons - their labels live in
`kAXTitleAttribute` and `kAXDescriptionAttribute`, not value. Most native UI
text was invisible.

One option was app-specific extractors (a "Calculator adapter", a "Slack
adapter") layered inside the primitive. That would pull app awareness into
Layer 0, which [ADR 1](0001-read-is-the-product.md) explicitly keeps out.

## Decision

A node's text is whichever of `value`, `title`, or `accessibility description`
is non-empty first, in that fixed priority order. The same rule runs for every
app. There is no role special-casing and no pluggable extraction strategy in
the primitive.

## Consequences

`ve` captures far more real on-screen text (Calculator went from 2 nodes to
194) while staying fully app-agnostic. App-specific interpretation stays in
Layer 1 adapters, where being wrong is cheap and expected.
