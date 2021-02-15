# Releasing New Finch Versions

The Finch release process is largely automated, however there are a few things you need to do to ensure a successful release. See [Publishing a release](#publishing-a-release) for instructions.

## Publishing a release

### Create and push a new tag
Depending on your scenario, see [Patch release](#patch-release) or [Major and minor releases](#major-and-minor-releases) for the appropriate steps.

#### Major and minor releases
1. Major and minor releases should be branched off of `main`.
1. Run `make publish NEW_VERSION` (replacing `NEW_VERSION` with the intended value).
1. Increment the version for the `main` branch.

#### Patch release
1. Patch releases should be branched off the most recent tag: `git checkout -b releases/NEW_VERSION TAG` (replacing `NEW_VERSION` and `TAG` with the intended values).
1. Apply the necessary changes to the release branch, cherry picking from `main` as appropriate.
1. Run `make publish NEW_VERSION` (replacing `NEW_VERSION` with the intended value).

### Sit back and relax
Pushing a new tag will kick of CI processes which manage the remainder of the release process. Sit back and relax (_and confirm the CI operations finish successfully_)...
