APP_NAME=DiffFormatter
BUILT_PRODUCT_PATH=$(PWD)/.build/release/$(APP_NAME)
INSTALL_ROOT=$(HOME)
INSTALL_PATH=/.$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')
INSTALL_DIR=$(INSTALL_ROOT)$(INSTALL_PATH)
BIN_DIR=$(INSTALL_DIR)/bin
CONFIG_TEMPLATE=config.json.template

# ZSH_COMMAND · run single command in `zsh` shell, ignoring most `zsh` startup files.
ZSH_COMMAND := ZDOTDIR='/var/empty' zsh -o NO_GLOBAL_RCS -c
# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY := $(ZSH_COMMAND) '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && noglob rm -rf $${1:A}' --

.PHONY: all build install config_template symlink lint setup test

all: install

## Install DiffFormatter
build: update_build_number
	swift build --configuration release -Xswiftc -static-stdlib

config_template:
	@echo "\nAdding config template to $(INSTALL_DIR)/$(CONFIG_TEMPLATE)"
	cp $(CONFIG_TEMPLATE) $(INSTALL_DIR)/$(CONFIG_TEMPLATE)

copy_build: build
	@echo "\nCopying executable to $(BIN_DIR)"
	mkdir -p $(BIN_DIR) && cp -L $(BUILT_PRODUCT_PATH) $(BIN_DIR)/$(APP_NAME)

install: build copy_build symlink config_template
 
## Swiftlint
lint:
	swiftlint --strict

## Setup project
setup:
	./Scripts/setup

symlink: build
	@echo "\nSymlinking $(APP_NAME)"
	ln -fs $(BIN_DIR)/$(APP_NAME) /usr/local/bin/$(APP_NAME)

## Run tests
test: update_build_number
	@$(RM_SAFELY) ./.build/debug/DiffFormatterPackageTests.xctest
	swift test 2>&1 | xcpretty

update_build_number:
	./Scripts/update-build-number

