# DiffFormatter

DiffFormatter is a configurable way to output version-to-version diffs for release documentation — (output specifically to Quip at the moment). The utility makes several assumptions about the desired format

# Configuration Setup
The following portions of DiffFormatter are configurable:
- User list
- Section Info title and corresponding tags
- Footer
## Search paths & behavior
DiffFormatter will start with a default configuration and will search several paths for overrides for your environment and project. Paths, with the behavior described as below, will be searched for files within `$SEARCH_PATH/.diff_formatter/config/` to modify configuration.

### Search Paths behavior
DiffFormatter will search 2 paths for configuration files. The behavior is described as follows
1. Home directory
2. Path found at included DIFF_FORMATTER_CONFIG environment variable __OR__ DiffFormatter's current directory if the previous env var is not present

*Note: For DIFF_FORMATTER_CONFIG, you should only include the path to the directory which contains your ".diff_formatter" directory. DiffFormatter will append the other expected path components*

## Configuration file formatting expectations
All config files should be readable with no file extension. The following specific file formats are expected for each of their corresponding categories if custom configuration is desired:
- User list
  - File name: `users`
  - Newline separated list
  - Each line should be formatted like the following (email, Quip username): `%%%jony.ive@apple.com%%%&&&Jony.Ive&&&`
- Section Info
  - File name: `section_infos`
  - Newline separated list
  - Each line should be formatted like the following (section title, comma-separated tags): `%%%Platform Improvements%%%&&&platform,dependencies,performance&&&`
  - Sections should be listed in the order you want them to be displayed in the output
  - Sections will be parsed in reverse and each commit will be placed into the first matching section (including matching a wild card)

- Footer
  - File name: `footer`
  - Any text included in this config file will be appended to the end of the formatted diff

# Example output
```
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