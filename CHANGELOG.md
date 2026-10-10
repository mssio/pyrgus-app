# Changelog

All notable changes to Pyrgus for iPhone, iPad and Mac are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/) (`MARKETING_VERSION`).

## [Unreleased]

### Added

- On iPhone and iPad, Support and Privacy Policy links in the About sheet.
- On Mac, an About window (Pyrgus › About Pyrgus, or ⓘ) with Support and Privacy Policy buttons.

### Changed

- The main screen no longer scrolls or bounces when everything fits.
- On Mac, the window can't be made smaller than its content.
- On iPhone, the app stays in portrait.

### Fixed

- On Mac, the top of the window no longer changes color when the pointer is over it.

### Release housekeeping

- `main` holds 1.0.1 (build 2) and 1.0.2 (build 3), merged before Git Flow and never published;
  the 1.0.2 release merge replaces them.

## [1.0.0] - 2026-09-27

### Added

- Passwords and secret keys generated on-device for iPhone, iPad and Mac: Password, Custom
  Password, Memorable, PIN, Secret 128 and Secret 256.
- A Home Screen widget on iPhone and iPad that copies a new secret without showing it.

[Unreleased]: https://github.com/mssio/pyrgus-app/compare/v1.0.0...develop
[1.0.0]: https://github.com/mssio/pyrgus-app/releases/tag/v1.0.0
