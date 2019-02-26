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
**Title / Tags**:  
As a prefix to the title of your PR, include square-bracketed tags indicating the purpose of the PR. Ideally, you should utilize existing tags, such as: `[feature]`, `[platform]`, `[bug fix]`. See [.finch/release_config.yml](.finch/release_config.yml) for additional examples.

**PR Body**:  
The body of the PR should include all context about the purpose of the pull request.

## Getting started
Finch uses `make` targets for the development, testing and release processes.

- To set up the project, run `make setup`
- To generate an Xcode project file, run `make xcodeproj`
- Code style should mostly follow Ray Wenderlich's [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide). If there is ambiguity, try to match the style of the surrounding code.  
  
*Note*: You may need to run `make update_build_number` prior to building the project in Xcode as this file is generated upon release time.

## Documentation
Finch strives for 100% documentation and uses [Jazzy](https://github.com/realm/jazzy) to generate doc pages. All types, variables and functions should be documented. See existing code for examples.

## Tests
- Finch uses the XCTest framework for unit and snapshot tests. In the majority of cases, a code change should be accompanied by the addition of tests surrounding that change.
- To run all tests, run `make test`

## Releasing
See [RELEASING.md](RELEASING.md)
