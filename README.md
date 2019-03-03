# Finch 🐦
![CircleCI branch](https://img.shields.io/circleci/project/github/namolnad/Finch/master.svg?style=for-the-badge)
![GitHub release](https://img.shields.io/github/release-pre/namolnad/Finch.svg?color=blue&style=for-the-badge)
![Platforms](https://img.shields.io/badge/Platforms-MacOS_Linux-Blue.svg?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-Blue.svg?style=for-the-badge)

Finch is a configurable tool designed to make tracking the history and evolution of a product simple and easy to automate. It transforms a project's commit messages into well-formatted, section-based version changelogs — tailored to your team's specific documentation needs. Finch requires a commit message square-bracket [tag] convention which it utilizes to determine an appropriate section into which a given commit should be placed. (e.g. `[cleanup] Remove legacy obj-c code`)

## Table of Contents
- [Why is it called 'Finch'?](#why-is-it-called-finch)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
  - [Config file location](#config-file-location)
  - [Config format](#config-format)
  - [Config merging and search behavior](#config-merging-and-search-behavior)
- [Contributing](#contributing)
- [Example output](#example-output)
- [License](#license)

### Why is it called 'Finch'?

The name Finch is derived from the purpose of the application itself — tracking the evolution of a product. Because evolution is at the core of Finch, it seemed appropriate to name it after an evolutionary landmark, Darwin's [finches](https://bit.ly/2TJZlnb).

## Installation
Finch is available via multiple installation methods:
- Installable package (**recommended**): Download and run the most recent [release](https://github.com/namolnad/Finch/releases)'s `Finch.pkg` file and follow the on-screen instructions
- Swift Package Manager: Add to your `Package.swift` file's dependencies: `.package(url: "https://github.com/namolnad/Finch.git", from: "0.0.17")` and call via `swift run finch compare`
- From source: If you’d like to build from source, you can clone this repository and run `make install` from the root of the cloned directory. This will install and link the Finch binary and will place a template config file at the following location `$HOME/.finch/template.config.yml`


## Usage
To generate a changelog you must run the `compare` command. If `compare` is passed no arguments, Finch will first look for the two most recent semantically-versioned branches then the two most recent semantically-versioned git tags. You can also explicitly pass two versions by using the `--versions` option and passing 2 version arguments (branch or tag). Other accepted argurments are:
1. The ability to hide the version header (`--no-show-version`)
1. Release manager (`--release-manager`)
1. Project directory (`--project-dir`) if Finch is not called from project directory
1. Manual git log (`--git-log`). Must be received in format: `git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short OLD_VERSION...NEW_VERSION`
1. Don't fetch origin before auto-generating changelog (`--no-fetch`).
1. Build number string to be included in version header (`--build-number`) Takes precedence over build number command in config. Example output: `6.19.1 (6258)`

In many cases it may be easiest to create a new shell function when your shell startup files are sourced, such as the following:

```
project-changelog() {
  finch compare $@ --project-dir="$HOME/Code/YourProject" --release-manager=$(git config --get user.email)
}

# Used in the following manner:
# project-changelog --versions 6.12.1 6.13.0
```

## Configuration
View Finch's configurable components in this [configuration template](Resources/template.config.yml).

### Config file location
Finch searches for a hidden `.finch` directory containing a `config.yml` file. The `.finch` directory can be placed in either the home, current, or project directories. Alternatively, if you provide a custom path through an env variable, Finch will look for a valid configuration file at the included path. Finch also allows for private config files in case you prefer to keep portions of your config outside your version-control sytem. See the [search behavior](#config-merging-and-search-behavior) below.

### Config format
`config.yml` should be a valid YAML file in the same format as this [config template](Resources/template.config.yml). (Note: Not all keys need to be included as Finch uses default values where needed. You can see an example config at any time by running `finch config show-example`.

### Config merging and search behavior
Finch will start with a default configuration and will search several paths for valid configuration files to override existing values. Any non-empty elements included in later configuration files will override their existing counterparts. Empty or omitted config file components will be ignored.

The config search paths will be executed in the following manner:
- Env var
  - FINCH_CONFIG
__OR__
- Built in defaults overridden w/ waterfall technique (searching each directory first for `config.yml`, then for `config.private.yml`)
  - Home directory
  - Finch's current directory
  - `--project-dir` argument

*Notes*
- Sections should be listed in the order you want them to be displayed in the output
- If included sections have duplicative tags, the last section with a given tag wins. Each matching commit will be placed into its owning section.
- One wildcard section can be included. Do so by including a * in the section's tag config.
- Commits will only appear in a single section. Searches first for a section matching the first commit tag, then the second and so on.
- Sections may be excluded by passing excluded: true in section config

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md)

## Example output
```
# 6.13.0 (3242)

### Release Manager

 - @User.2

### Features
 - |wip||custom-lib| initial work on incorporating 1.0.0 — [PR #912](https://github.com/your_repo/pull/912) — @User.3
 - |checkout| improved tracking + logging — [PR #958](https://github.com/your_repo/pull/958) - @User.2

### Bug Fixes
 - |cleanup| remove unused obj-c experiment, fix some warnings — [PR #949](https://github.com/your_repo/pull/949) — @User.1
 - |cleanup| remove unused Lib — [PR #947](https://github.com/your_repo/pull/947) - @User.3

### Platform Improvements
 - |tooling| re-enable new build system — [PR #959](https://github.com/your_repo/pull/959) — @User.1
 - |platform| move to incremental compilation and ensure we're using same swift version across the board — [PR #966](https://github.com/your_repo/pull/966) — @User.2

### Timeline
 - Begin development:
 - Feature cut-off / Start of bake / dogfooding:
 - Submission:
 - Release (expected):
 - Release (actual):

```

## License
Finch is released under the [MIT License](LICENSE.md)
