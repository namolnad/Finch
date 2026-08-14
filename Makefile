APP_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(APP_NAME_LOWERCASE)
APP_NAME=Finch
APP_NAME_LOWERCASE=$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')
APP_TMP=/tmp/$(APP_NAME).dst
BIN_DIR=$(INSTALL_DIR)/bin
BINARIES_DIR=/usr/local/bin
BUILD=swift build
BUILD_NUMBER_FILE=./Sources/$(APP_NAME)/App/BuildNumber.swift
CONFIG_TEMPLATE=template.config.yml
CP=cp
DISTRIBUTION_PLIST=$(APP_TMP)/Distribution.plist
INSTALL_DIR=$(HOME)/.$(APP_NAME_LOWERCASE)
INTERNAL_PACKAGE=$(APP_NAME)App.pkg
LN=ln -fs
MKDIR=mkdir -p
ORG_IDENTIFIER=org.$(APP_NAME_LOWERCASE).$(APP_NAME_LOWERCASE)
OUTPUT_PACKAGE=$(APP_NAME).pkg
SWIFT_BUILD_FLAGS=--configuration release $(SWIFT_RESOLUTION_FLAGS)
# A build resolves a narrower graph than the tests do, and would otherwise prune
# the test-only pins out of Package.resolved on the way past, so it is pinned to
# the file. The tests are deliberately left unpinned: Package.resolved gets
# regenerated from the build graph by tooling which knows nothing of FINCH_TESTS
# — dependabot, for one — and pinning the tests turns every such update into a
# CI failure instead of a resolution.
SWIFT_RESOLUTION_FLAGS=--only-use-versions-from-resolved-file
TEST=FINCH_TESTS=1 swift test
VERSION_FILE=./Sources/$(APP_NAME)/App/Version.swift
VERSION_STRING=$(shell cat $(VERSION_FILE) | grep appVersion | sed -n -e 's/^.*(//p' | tr -d ") " | sed -e 's/[a-z]*://g' | tr "," ".")

# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY := bash -c '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && set -o noglob && rm -rf $${1:A}' --


.PHONY: all build build_with_disable_sandbox config_template install lint package prefix_install symlink tag_release test update_build_number update_version

all: install

build: update_build_number
	$(BUILD) $(SWIFT_BUILD_FLAGS)

build_with_disable_sandbox: update_build_number
	$(BUILD) --disable-sandbox $(SWIFT_BUILD_FLAGS)

config_template:
	@echo "\nAdding config template to $(INSTALL_DIR)/$(CONFIG_TEMPLATE)"
	$(MKDIR) $(INSTALL_DIR)
	$(CP) Resources/$(CONFIG_TEMPLATE) $(INSTALL_DIR)/

install: build symlink config_template
	install -d $(BIN_DIR)
	install $(APP_EXECUTABLE) $(BIN_DIR)/

lint:
	mint run swiftlint swiftlint --strict

package: build
	$(MKDIR) $(APP_TMP)
	$(CP) $(APP_EXECUTABLE) $(APP_TMP)

	pkgbuild \
	  --identifier $(ORG_IDENTIFIER) \
	  --install-location $(BINARIES_DIR) \
	  --root $(APP_TMP) \
	  --version $(VERSION_STRING) \
	  $(INTERNAL_PACKAGE)

	productbuild \
	  --synthesize \
	  --package $(INTERNAL_PACKAGE) \
	  $(DISTRIBUTION_PLIST)

	productbuild \
	  --distribution $(DISTRIBUTION_PLIST) \
	  --package-path $(INTERNAL_PACKAGE) \
	  $(OUTPUT_PACKAGE)

	@$(RM_SAFELY) $(APP_TMP)
	@$(RM_SAFELY) $(INTERNAL_PACKAGE)

prefix_install:
	@NO_UPDATE_BUILD_NUMBER=1 $(MAKE) build_with_disable_sandbox
	install -d "$(PREFIX)/bin"
	install "$(APP_EXECUTABLE)" "$(PREFIX)/bin/"
	@$(MAKE) config_template

symlink: build
	@echo "\nSymlinking $(APP_NAME)"
	$(LN) $(BIN_DIR)/$(APP_NAME_LOWERCASE) $(BINARIES_DIR)

# Commits the version and build number into a local tag, leaving the branch as
# it was. The build number is regenerated after the commit so that it counts the
# commit it ships in. Pushing the tag is the caller's business.
tag_release:
ifndef NEW_VERSION
	$(error NEW_VERSION is required. e.g. `make tag_release NEW_VERSION=0.4.0`)
endif
	@$(MAKE) update_version
	git add $(VERSION_FILE)
	git commit --allow-empty -m "[version] Publish version $(NEW_VERSION)"
	@$(MAKE) update_build_number
	git add -f $(BUILD_NUMBER_FILE)
	git commit --amend --no-edit
	git tag $(NEW_VERSION)

test: update_build_number
	@$(RM_SAFELY) ./.build/debug/$(APP_NAME)PackageTests.xctest
	$(TEST)

update_build_number:
ifndef NO_UPDATE_BUILD_NUMBER
	@echo "let appBuildNumber: Int = $(shell git rev-list @ --count)" > $(BUILD_NUMBER_FILE)
endif

update_version:
ifdef NEW_VERSION
	$(eval VERSION_COMPONENTS:=$(subst ., ,$(NEW_VERSION)))
	$(eval MAJOR:=$(word 1,$(VERSION_COMPONENTS)))
	$(eval MINOR:=$(word 2,$(VERSION_COMPONENTS)))
	$(eval PATCH:=$(word 3,$(VERSION_COMPONENTS)))
	@echo "import Version\n\nlet appVersion: Version = .init(major: $(MAJOR), minor: $(MINOR), patch: $(PATCH))" > $(VERSION_FILE)
endif
