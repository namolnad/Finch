# DiffFormatter

DiffFormatter is a configurable way to output version-to-version diffs for Markdown-formatted release documentation. The utility makes several assumptions about the desired format, and utilizes commit "tag" formatting (`[cleanup] Remove legacy obj-c code`) to determine the appropriate section in which a commit should be placed.

# Usage
The first two arguments received must be the version strings, in order of: OLD_VERSION NEW_VERSION (branch or tag). Other accepted argurments are:
1. The ability to hide the version header (`--no-show-version`)
2. Release manager (`--release-manager`)
3. Project directory (`--project-dir`) if DiffFormatter is not called from project directory
4. Manual git diff (`--git-diff`). Must be received in format: git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short OLD_VERSION...NEW_VERSION
5. Don't fetch origin before auto-generating diff (`--no-fetch`).
6. Build number string to be included in version header (`--build-number`) Takes precedence over build number command in config. Example output: `6.19.1 (6258)`

In many cases it may be easiest to create a new shell function when your shell startup files are sourced, such as the following:

```
format-version-diff() {
  DiffFormatter $@ --project-dir="$HOME/Code/YourProject" --release-manager=$(git config --get user.email)
}

# Used in the following manner:
# format-version-diff 6.12.1 6.13.0
```

# Configuration Setup
The following portions of DiffFormatter are configurable:
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

To function properly, DiffFormatter requires at least a contributors list.

## File Type & Search Behavior
DiffFormatter will start with a default configuration and will search several paths for configuration overrides. It expects a hidden `.diff_formatter` file with no extension, placed in either the home, current or a custom directory. For instance, if you provide a custom path through an env variable, DiffFormatter will attempt to find a valid configuration file at: `$DIFF_FORMATTER_CONFIG/.diff_formatter`.

The config search paths will be executed in the following mannger:
- Env var
  - DIFF_FORMATTER_CONFIG
__OR__
- Built in defaults overridden w/ waterfall technique
  - Home directory
  - DiffFormatter's current directory
  - --proj-dir argument

Any non-empty configuration variables included in the config file found in each step will overwrite the existing configuration. Empty or omitted config file components will be ignored. Configuration customization is not additive to the existing configuration.

## Configuration file formatting expectations
`.diff_formatter` should be a valid JSON file with the following format. Top level keys may be ommitted if a previous configuration has fully configured the setting as desired.

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
      "format_string": " - <<tags>> <<message>> — <<commit_type_hyperlink>> — <<contributor_handle>>",
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
