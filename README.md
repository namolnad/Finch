# Finch 🐦

Finch is a configurable tool designed to make tracking the history and evolution of a product simple and easy to automate. It transforms a project's commit messages into well-formatted, section-based version changelogs — tailored to your team's specific documentation needs. Finch requires a commit message square-bracket [tag] convention which it utilizes to determine an appropriate section into which a given commit should be placed. (e.g. `[cleanup] Remove legacy obj-c code`)

### Why 'Finch'?

The name Finch is derived from the purpose of the application itself — tracking the evolution of a product. Because evolution is at the core of Finch, it seemed appropriate to name it after an evolutionary landmark, Darwin's [finches](https://bit.ly/2TJZlnb).

# Installation
Finch is available via multiple installation methods:
- Installable package (**recommended**): Download and run the most recent [release](https://github.com/namolnad/Finch/releases)'s `Finch.pkg` file and follow the on-screen instructions
- Swift Package Manager: Add to your `Package.swift` file's dependencies: `.package(url: "https://github.com/namolnad/Finch.git", from: "0.0.17")` and call via `swift run finch compare`
- From source: If you’d like to build from source, you can clone this repository and run `make install` from the root of the cloned directory. This will install and link the Finch binary and will place a template config file at the following location `$HOME/.finch/config.json.template`


# Usage
To generate a changelog you must run the `compare` command. If `compare` is passed no arguments, Finch will first look for the two most recent semantically-versioned branches then the two most recent semantically-versioned git tags. You can also explicitly pass two versions by using the `--versions` option and passing 2 version arguments (branch or tag). Other accepted argurments are:
1. The ability to hide the version header (`--no-show-version`)
2. Release manager (`--release-manager`)
3. Project directory (`--project-dir`) if Finch is not called from project directory
4. Manual git log (`--git-log`). Must be received in format: git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short OLD_VERSION...NEW_VERSION
5. Don't fetch origin before auto-generating changelog (`--no-fetch`).
6. Build number string to be included in version header (`--build-number`) Takes precedence over build number command in config. Example output: `6.19.1 (6258)`

In many cases it may be easiest to create a new shell function when your shell startup files are sourced, such as the following:

```
project-changelog() {
  finch compare $@ --project-dir="$HOME/Code/YourProject" --release-manager=$(git config --get user.email)
}

# Used in the following manner:
# project-changelog --versions 6.12.1 6.13.0
```

# Configuration Setup
The following portions of Finch are configurable:
- Contributor list
- Contributor handle prefix
- Section info (title and corresponding tags)
- Section's line format
- Tag input and output delimiters
- Footer (Appended to the end of the formatted diff as a simple string)
- Git executable path
- Git branch (or tag) prefix
- Git repo base url
- Build number generation command

To function properly, Finch requires at least a contributors list.

## File Type & Search Behavior
Finch will start with a default configuration and will search several paths for configuration overrides. It expects a hidden `.finch` directory containing a `config.json` file. The `.finch` directory can placed in either the home, current, or project directories. Alternatively, if you provide a custom path through an env variable, Finch will look for a valid configuration file at the included path.

The config search paths will be executed in the following mannger:
- Env var
  - FINCH_CONFIG
__OR__
- Built in defaults overridden w/ waterfall technique
  - Home directory
  - Finch's current directory
  - `--project-dir` argument

Any non-empty configuration variables included in the config file found in each step will overwrite the existing configuration. Empty or omitted config file components will be ignored. Configuration customization is not additive to the existing configuration.

## Configuration file formatting expectations
`config.json` should be a valid JSON file with the following format. Top level keys may be omitted if a previous configuration has fully configured the setting as desired.

```
{
  "contributors_config": {
    "contributors": [
      {
        "email": "jony.ive@apple.com",
        "quip_handle": "Jony.Ive"
      },
      {

        "email": "tony.stark+junk@gmail.com",
        "quip_handle": "Tony.Stark"
      }
    ],
    "contributor_handle_prefix": "%"
  },
  "section_infos": [
    {
      "title": "Features",
      "tags": [
        "feature",
        "tag 2"
      ],
      "format_string": " - << tags >> << message >> — << commit_type_hyperlink >> — << contributor_handle >>",
      "capitalizes_message": true,
      "excluded": true
    }
  ],
  "footer": "Custom footer here",
  "delimiter_config": {
    "output": {
        "left": "**❲**",
        "right": "**❳**"
    }
  },
  "git_config": {
    "branch_prefix": "origin/releases/",
    "repo_base_url": "https://github.com/org/repo"
  },
  "build_number_command_arguments": [
    "/usr/bin/env",
    "bash",
    "-c",
    "git rev-list --count origin/releases/$NEW_VERSION"
  ]
}
```

*Notes*
  - Sections should be listed in the order you want them to be displayed in the output
  - If included sections have duplicative tags, the last section with a given tag wins. Each matching commit will be placed into it's owning section.
  - One wildcard section can be included. Do so by including a * in the section's tag config.
  - Commits will only appear in a single section. Searches first for a section matching the first commit tag, then the second and so on.
  - Sections may be excluded by passing `excluded: true` in section config

# Example output
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
