# Contributing
Thank you for your interest in contributing to Finch! Below you'll find information and rules on how to start contributing.

## Table of contents
- [Pull requests](#pull-requests)
  - [PR format](#pr-format)
- [Getting started](#getting-started)
- [Documentation](#documentation)
- [Tests](#tests)
- [Releasing](#releasing)

## Pull requests
All changes must be made via pull requests. PRs are preferred over issue submission where possible.

#### PR format
**Title / Tags**:\
As a prefix to the title of your PR, include square-bracketed tags indicating the purpose of the PR. Ideally, you should utilize existing tags, such as: `[feature]`, `[platform]`, `[bug fix]`. See [.finch/config.release.yml](.finch/config.release.yml) for additional examples.

**PR Body**:\
The body of the PR should include all context about the purpose of the pull request.

## Getting started
Finch uses `make` targets for the development, testing and release processes.

- To build and install the binary, run `make install`
- To work in Xcode, open `Package.swift` directly
- To lint, run `make lint` (install the linters first with `brew bundle` and `mint bootstrap`)
- Code style should mostly follow Ray Wenderlich's [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide). If there is ambiguity, try to match the style of the surrounding code.

*Note*: You may need to run `make update_build_number` prior to building the project, as this file is generated at release time and is not tracked in version control.

## Documentation
Finch strives for 100% documentation. All types, variables and functions should be documented. See existing code for examples. Types which are implementation detail rather than public surface are marked `:nodoc:`.

## Tests
- Finch uses the XCTest framework for unit and snapshot tests. In the majority of cases, a code change should be accompanied by the addition of tests surrounding that change.
- To run all tests, run `make test`

## Releasing
See [RELEASING.md](RELEASING.md)
