APP_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(APP_NAME)
APP_NAME=Finch
APP_NAME_LOWERCASE=$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')
APP_TMP=/tmp/$(APP_NAME).dst
BIN_DIR=$(INSTALL_DIR)/bin
BINARIES_DIR=/usr/local/bin
BUILD=swift build
BUILD_NUMBER_FILE=./Sources/$(APP_NAME)/App/BuildNumber.swift
CONFIG_TEMPLATE=template.config.yml
CONFIRM=./Scripts/prompt_confirmation
CP=cp
CURRENT_BRANCH=git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'
DISTRIBUTION_PLIST=$(APP_TMP)/Distribution.plist
DOCS=docs
INSTALL_DIR=$(HOME)/.$(APP_NAME_LOWERCASE)
INTERNAL_PACKAGE=$(APP_NAME)App.pkg
JAZZY=bundle exec jazzy --module-version $(VERSION_STRING)
LN=ln -fs
MKDIR=mkdir -p
ORG_IDENTIFIER=org.$(APP_NAME_LOWERCASE).$(APP_NAME_LOWERCASE)
OUTPUT_PACKAGE=$(APP_NAME).pkg
PIPEFAIL=set -o pipefail
SWIFT_BUILD_FLAGS=--configuration release
VERSION_FILE=./Sources/$(APP_NAME)/App/Version.swift
VERSION_STRING=$(shell cat $(VERSION_FILE) | grep appVersion | sed -n -e 's/^.*(//p' | tr -d ") " | tr "," ".")

# ZSH_COMMAND · run single command in `zsh` shell, ignoring most `zsh` startup files.
ZSH_COMMAND := ZDOTDIR='/var/empty' zsh -o NO_GLOBAL_RCS -c
# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY := $(ZSH_COMMAND) '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && noglob rm -rf $${1:A}' --


.PHONY: all build build_with_disable_sandbox config_template install lint package prefix_install xcodeproj publish setup symlink test update_build_number update_version

all: install

build: update_build_number
	$(BUILD) $(SWIFT_BUILD_FLAGS)

build_with_disable_sandbox: update_build_number
	$(BUILD) --disable-sandbox $(SWIFT_BUILD_FLAGS)

config_template:
	@echo "\nAdding config template to $(INSTALL_DIR)/$(CONFIG_TEMPLATE)"
	$(MKDIR) $(INSTALL_DIR)
	$(CP) Resources/$(CONFIG_TEMPLATE) $(INSTALL_DIR)/

docs: xcodeproj
	$(JAZZY) --config .jazzy/FinchApp.yml -o $(DOCS)/FinchApp
	$(JAZZY) --config .jazzy/FinchCore.yml -o $(DOCS)/FinchCore

install: build symlink config_template
	install -d $(BIN_DIR)
	install $(APP_EXECUTABLE) $(BIN_DIR)/

lint:
	swift run swiftlint --strict

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

publish: test
	$(eval NEW_VERSION:=$(filter-out $@, $(MAKECMDGOALS)))
	@$(CONFIRM) "Warning: This will force create and push a tag for '$(NEW_VERSION)' \
	based off the current state of the current branch: $(CURRENT_BRANCH)."
	@NEW_VERSION=$(NEW_VERSION) $(MAKE) update_version
	git add $(VERSION_FILE)
	git commit --allow-empty -m "[version] Publish version $(NEW_VERSION)"
	@$(MAKE) update_build_number
	cat $(BUILD_NUMBER_FILE)
	git add -f $(BUILD_NUMBER_FILE)
	git commit --amend --no-edit
	git tag -f $(NEW_VERSION)
	git push origin $(NEW_VERSION) -f

setup:
	swift run komondor install

symlink: build
	@echo "\nSymlinking $(APP_NAME)"
	$(LN) $(BIN_DIR)/$(APP_NAME) $(BINARIES_DIR)

test: update_build_number
	@$(RM_SAFELY) ./.build/debug/$(APP_NAME)PackageTests.xctest
	$(PIPEFAIL) && swift test 2>&1 | xcpretty -r junit --output build/reports/test/junit.xml

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
	@echo "import struct Utility.Version\n\nlet appVersion: Version = .init($(MAJOR), $(MINOR), $(PATCH))" > $(VERSION_FILE)
endif

xcodeproj:
	swift package generate-xcodeproj --enable-code-coverage

%:
	@:
