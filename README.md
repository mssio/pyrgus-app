# Pyrgus

Passwords and secret keys for iPhone, iPad and Mac, generated on-device with the system CSPRNG.
No account, no network. A Home Screen widget opens Pyrgus to copy or regenerate a secret,
never showing it on the Home Screen.

Formats: Password, Custom Password (6–32 characters, symbols optional), Memorable (4–8 EFF words),
PIN (4, 6 or 8 digits), Secret 128 and Secret 256 (hex). The web version is
[Pyrgus Web](https://p.mss.io); both share the same formats and test vectors.

## Build

Requires Xcode 27 and XcodeGen 2.46.0.

    xcodegen generate
    open Pyrgus.xcodeproj

Tests: `cd Packages/PasswordKit && swift test`.

Rules for contributors and coding agents are in [`AGENTS.md`](AGENTS.md).

## Credits

Memorable passwords use the [EFF long wordlist](https://www.eff.org/dice), licensed CC BY 3.0 US.
