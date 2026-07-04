# 3. Distribute unsigned via a Homebrew tap

Status: accepted

## Context

`ve` is a downloaded macOS binary, so Gatekeeper is a concern: a binary that
carries the `com.apple.quarantine` attribute (attached to browser/`curl`
downloads) is blocked on first run unless it is signed with a Developer ID
certificate and notarized. Setting that up requires an Apple Developer account
and credentials.

Two facts make signing optional for the first release. On Apple Silicon every
binary is already ad-hoc signed by the linker, so it runs locally. And
Homebrew does not apply the quarantine attribute to binaries it installs, so a
tool installed via `brew install` is not subject to the Gatekeeper prompt even
when it lacks a Developer ID signature.

## Decision

Distribute `ve` through a personal Homebrew tap (`mmurakaru/homebrew-tap`,
installed as `brew install mmurakaru/tap/ve`), unsigned. The first release is
tagged `v1.0.0-rc.1` as a prerelease. Developer ID signing and notarization are
deferred; they become worthwhile only if raw GitHub Release downloads (which do
carry quarantine) become a supported install path.

## Consequences

The release ships with no Apple credentials and no signing infrastructure.
Homebrew users are unaffected by Gatekeeper. Anyone who instead downloads the
release tarball directly must clear quarantine themselves (`xattr -d
com.apple.quarantine ...`) until signing is added.
