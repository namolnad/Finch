APP_NAME=DiffFormatter
BIN_DIR=$(INSTALL_DIR)/bin
CONFIG_TEMPLATE=config.json.template
INSTALL_DIR=$(HOME)/.$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')
BUILD_NUMBER_FILE=./Sources/$(APP_NAME)/App/BuildNumber.swift

SWIFT_BUILD_FLAGS=--configuration release -Xswiftc -static-stdlib
APP_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(APP_NAME)

# ZSH_COMMAND · run single command in `zsh` shell, ignoring most `zsh` startup files.
ZSH_COMMAND:=ZDOTDIR='/var/empty' zsh -o NO_GLOBAL_RCS -c
# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY:=$(ZSH_COMMAND) '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && noglob rm -rf $${1:A}' --

BUILD=swift build
CP=cp
MKDIR=mkdir -p

.PHONY: all build build_with_disable_sandbox config_template install lint prefix_install publish symlink test update_build_number

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
	swiftlint --strict

prefix_install: build_with_disable_sandbox
	install -d "$(PREFIX)/bin"
	install "$(APP_EXECUTABLE)" "$(PREFIX)/bin/"
	@$(MAKE) config_template

publish:
	$(eval NEW_VERSION := $(filter-out $@, $(MAKECMDGOALS)))
	git checkout master
	git checkout -b releases/$(NEW_VERSION)
	git commit -m --allow-empty "[version] Publish version $(NEW_VERSION)"
	@$(MAKE) update_build_number
	git add -f $(BUILD_NUMBER_FILE)
	git commit --amend --no-edit
	git tag $(NEW_VERSION)
	git push origin $(NEW_VERSION)

symlink: build
	@echo "\nSymlinking $(APP_NAME)"
	ln -fs $(BIN_DIR)/$(APP_NAME) /usr/local/bin/

test: update_build_number
	@$(RM_SAFELY) ./.build/debug/$(APP_NAME)PackageTests.xctest
	swift test 2>&1 | xcpretty -r junit --output build/reports/test/junit.xml

update_build_number:
	./Scripts/update-build-number

