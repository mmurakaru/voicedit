# 1. `ve` is the product, not a voice editor

Status: accepted

## Context

voicedit began as a voice-driven text editor: hold a hotkey, speak an
instruction, a local LLM rewrites text in place. The durable value in that
system turned out to be the smallest piece - reliably getting an app's
on-screen text out through the macOS Accessibility API. The voice capture,
LLM inference, and text injection were the replaceable parts.

## Decision

voicedit is a single primitive, the `ve` CLI: it dumps the accessibility
tree of an application as a versioned JSON envelope. Voice, LLM, and injection
are dropped entirely, not deferred to a later layer. Apps that want to
interpret `read`'s output for their own purposes do so as separate, disposable
adapters that consume it (Layer 1) - the primitive itself has no app
awareness.

## Consequences

`ve` stays small, boring, and composable, and its JSON contract is the only
thing consumers depend on. Anything richer - editing, summarizing, voice - is
built on top by something else, and its churn never touches the primitive.
