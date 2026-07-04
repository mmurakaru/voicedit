# 1. The primitive is `ve`, the perception layer

Status: accepted

## Context

voicedit began as a voice-driven text editor: hold a hotkey, speak an
instruction, a local LLM rewrites text in place. The hard, durable part of that
was never the speech-to-text or the LLM - both are solved and run locally. It
was giving the assistant the context of what is on screen right now: reliably
getting an app's on-screen text out through the macOS Accessibility API.

The use-case that motivates everything: you are on a Slack thread, an email, a
ticket, and you want to act on it hands-free - "summarize this", "draft a
reply", "what was decided?". None of that works without a perception layer that
turns the frontmost app into structured text.

## Decision

Build that perception layer first, alone, as the primitive: the `ve` CLI dumps
the accessibility tree of an application as a versioned JSON envelope. It
contains no voice, LLM, or text injection, and it has no app awareness - apps
that want to interpret its output do so as separate, disposable adapters
(Layer 1).

Voice and the LLM are not abandoned; they are the voicedit vision's later
layers, composed on top of `ve` rather than baked into it. Keeping them out of
the primitive is what lets the primitive stay thin and reusable.

## Consequences

`ve` stays small, boring, and composable, and its JSON contract is the only
thing consumers depend on. The voice-productivity layer, when it comes, is one
consumer of `ve` among others (a Slack adapter, a summarizer, an agent's
screen-perception tool) - and its churn never touches the primitive.
