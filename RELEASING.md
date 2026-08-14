# Releasing New Finch Versions

Releases are cut by the [Release workflow](.github/workflows/release.yml), which runs the tests, tags the release, builds the package, generates the changelog and publishes it to GitHub. Nothing needs to be built or pushed from a local machine.

## Publishing a release

1. Go to **Actions → Release → Run workflow**.
1. Choose the branch or tag to release from — `main` for major and minor releases, a release branch for a patch (see [Patch releases](#patch-releases)).
1. Enter the version, in `MAJOR.MINOR.PATCH` form.
1. Leave **Mark the GitHub release as a pre-release** checked unless you intend a full release.

The workflow refuses to run if the version is malformed or its tag already exists, so a mistyped version fails before anything is published.

### What it does
1. Runs the full test suite. A failure here stops the release.
1. Writes the version into `Version.swift`, regenerates `BuildNumber.swift`, and commits both into the tag. That commit lives only on the tag — the branch is left untouched.
1. Builds `Finch.pkg`.
1. Generates the changelog with Finch itself, comparing the two most recent tags using [.finch/config.release.yml](.finch/config.release.yml).
1. Creates the GitHub release with the changelog as its notes and the package attached.

### Patch releases
Patch releases should be branched off the most recent tag: `git checkout -b releases/NEW_VERSION TAG` (replacing `NEW_VERSION` and `TAG` with the intended values). Apply the necessary changes to the release branch, cherry picking from `main` as appropriate, push it, then run the Release workflow against that branch.

### Afterwards
`main` carries the *next* version rather than the released one, so increment `Version.swift` there when a release settles. Running `make tag_release NEW_VERSION=x.y.z` locally performs the same version bump, commit and tag as the workflow without pushing anything, which is useful for verifying the tagged contents.

The [Homebrew formula](https://github.com/namolnad/formulae) is not updated by this workflow and still needs its version and checksum bumped by hand.
