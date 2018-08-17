# DiffFormatter

DiffFormatter is a configurable way to output version-to-version diffs for release documentation — (output specifically to Quip at the moment). The utility makes several assumptions about the desired format, and utilizes commit tag formatting (`[cleanup] Remove legacy obj-c code`) to determine the appropriate section in which a commit should be placed.

# Usage
The first argument received must be a properly formatted git diff, using the following command: `git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short OLD_BRANCH...NEW_BRANCH`
Additionally, a version (`--version`) and release manager (`--release-manager`) argument may be passed in. In many cases it may be easiest to create a new shell function when your shell startup files are sourced, such as the following:

```
format-version-diff() {
  version_diff=$(git log --left-right --graph --cherry-pick --oneline --format=format:'&&&%H&&& - @@@%s@@@###%ae###' --date=short origin/releases/$1...origin/releases/$2)
  DiffFormatter "$version_diff" --version=$2 --release-manager=$(git config --get user.email)
}

# used in the following manner:
# format-version-diff 6.12.1 6.13.0
```

# Configuration Setup
The following portions of DiffFormatter are configurable:
- User list
- Section info (title and corresponding tags)
- Footer (Appended to the end of the formatted diff as a simple string)

To function properly, DiffFormatter requires a single configuration file with a users list at a bare minimum.

## Search paths & behavior
DiffFormatter will start with a default configuration and will search several paths for configuration overrides. The expectations and behavior is as follows:

### File Location
Whether or not you provide a custom path, your config file needs to be placed in a hidden `.diff_formatter` directory. For instance, if you provide a custom path, DiffFormatter will attempt to find a valid configuration file at: `$DIFF_FORMATTER_CONFIG/.diff_formatter/config.json`. The same format is expected if you want to keep config files in your home or project directories.

### Search Paths behavior
DiffFormatter will search a total of 2 paths for custom configuration files in the following order:
1. Home directory
2. Path found at included DIFF_FORMATTER_CONFIG environment variable __OR__ DiffFormatter's current directory if the previous env var is not present

Any non-empty configuration variables included in the config file found in each step will overwrite the existing configuration. Empty or non-existent config file components will be ignored. Configuration customization is not additive to the existing configuration.

## Configuration file formatting expectations
`config.json` should be a valid JSON file with the following format. Top level keys may be ommitted if a previous configuration has fully configured the setting as desired.

```
{
  "users": [
    {
      "email": "jony.ive@apple.com",
      "quip_handle": "Jony.Ive"
    },
    {

      "email": "tony.stark+junk@gmail.com",
      "quip_handle": "Tony.Stark"
    }
  ],
  "section_infos": [
    {
      "title": "Features",
      "tags": [
        "feature",
        "tag 2"
      ]
    }
  ],
  "footer": "Custom footer here"
}
```

*Notes*
  - Sections should be listed in the order you want them to be displayed in the output
  - Sections will be parsed in reverse and each commit will be placed into the first matching section (including matching a wild card)

# Example output
```
# 6.13.0

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