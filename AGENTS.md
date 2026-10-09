# AGENTS.md — rules for coding agents (Pyrgus app)

This repo sits in the Pyrgus workspace (`..`). The workspace `AGENTS.md` holds the shared rules: one
project per task, git workflow, specs and plans, downloads and installs. This file holds the rules
for this repo's code.

## What this is

Pyrgus: a native iPhone, iPad and Mac app, plus an iOS/iPadOS Home Screen widget, that generates
passwords and secret keys on-device with the system CSPRNG. No network, no account. The spec at
`../docs/app/specs/2026-09-26-pyrgus-apple-design.md` (outside this repo) is the source of truth; a
change to the design updates it in a paired commit.

## Commands

- `cd Packages/PasswordKit && swift test` — PasswordKit tests, on macOS, in seconds
- `xcodegen generate` — regenerate `Pyrgus.xcodeproj`; run after changing `project.yml` and after
  adding or removing any file under `App/` or `Widget/`
- `xcodebuild -project Pyrgus.xcodeproj -scheme Pyrgus -allowProvisioningUpdates -destination 'platform=iOS Simulator,name=iPhone 17' build`
- `xcodebuild -project Pyrgus.xcodeproj -scheme Pyrgus -allowProvisioningUpdates -destination 'platform=macOS' build`

Before claiming any task done: `swift test` passes and both builds print `** BUILD SUCCEEDED **`.

## Layout

- `Packages/PasswordKit/Sources/PasswordKit/` — formats, generation, entropy, wordlist, CSPRNG; no UI
- `Packages/PasswordKit/Sources/PasswordClipboard/` — the only platform-divergent code
- `Packages/PasswordKit/Tests/PasswordKitTests/` — Swift Testing; `test-vectors.json` and test support
- `App/` — SwiftUI app for iOS, iPadOS and macOS
- `Widget/` — iOS/iPadOS widget extension
- `project.yml` — XcodeGen source of truth; `Pyrgus.xcodeproj` and the `Info.plist` files are generated

## Git workflow

- Never commit to `main`. Cut a feature branch (`feat/…`, `fix/…`, `chore/…`, `docs/…`) from an
  up-to-date `origin/main`.
- Finish every task by pushing the branch and opening a **draft** PR with `gh pr create --draft`.
  The user marks it ready and merges (squash).
- Never commit `Pyrgus.xcodeproj`, the generated `Info.plist` files or build output.

## Security rules (non-negotiable)

- All production randomness goes through `SecureRandomNumberGenerator` (`SecRandomCopyBytes`). Never
  `SystemRandomNumberGenerator`, `arc4random`, or a `random` call without `using:`. Tests inject
  `SeededGenerator`. _A biased or predictable password is a silent failure._
- Never reduce with `x % n`: use `Int.random(in:using:)`, `randomElement(using:)`, `shuffled(using:)`.
- Fail closed: a randomness failure is a `preconditionFailure`, never a fallback value.
- No network access, analytics or third-party packages. Ask before adding any Swift package.
- Never persist, log or `print` a generated secret. Only the format and its options go to
  `UserDefaults`.
- The widget never displays a secret, only its `SecretMask`.

## Code conventions

- `PasswordKit` imports no UI framework. Platform code lives only in `PasswordClipboard`.
- Formats are data (`PasswordFormat.spec`), not branches in the generator.
- `#if os(...)` only for the clipboard, haptics, window sizing and the Mac About window.
- Swift 6 language mode. Tests use Swift Testing (`import Testing`); PasswordKit is test-first.
- Views are presentational; `PasswordModel` owns screen state.

## Cross-platform parity

`Packages/PasswordKit/Tests/PasswordKitTests/test-vectors.json` is a copy of Pyrgus Web's
`src/core/test-vectors.json`. Never edit it here: a change to formats, alphabets, entropy or the
wordlist starts in Pyrgus Web and is copied over as a separate task. Never edit `pyrgus-web` while
working here.

## Scope

Change code only inside this repository; specs go in `../docs/app/specs/`, plans in
`../docs/app/plans/`.
