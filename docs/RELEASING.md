# Releasing New Finch Versions

The Finch release process is largely automated, however there are a few things you need to ensure prior to publishing a new release.

## Publishing a release

### Create and push a new tag
See [Patch release](#p-release) or [Major/minor release](#mm-release) for the appropriate next steps.

#### Patch release {#p-release}
1. Patch releases should be branched off the most recent tag: `git checkout -b releases/NEW_VERSION TAG` (replacing `NEW_VERSION` and `TAG` with the intended values).
1. Apply the necessary changes to the release branch, cherry picking from `master` as appropriate.
1. Run `make publish NEW_VERSION` (replacing `NEW_VERSION` with the intended value).

#### Major/minor release {#mm-release}
1. Major and minor releases should be branched off of `master`.
1. Run `make publish NEW_VERSION` (replacing `NEW_VERSION` with the intended value).
1. Increment the version for the `master` branch.

## Sit back and relax
Pushing a new tag will kick of CI processes which manage the remainder of the release process. Sit back and relax (_and confirm the CI operations finish successfully_)...
