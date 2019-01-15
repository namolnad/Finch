APP_NAME=DiffFormatter
BIN_DIR=$(INSTALL_DIR)/bin
CONFIG_TEMPLATE=config.json.template
INSTALL_DIR=$(HOME)/.$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')

SWIFT_BUILD_FLAGS=--configuration release -Xswiftc -static-stdlib
APP_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(APP_NAME)

# ZSH_COMMAND · run single command in `zsh` shell, ignoring most `zsh` startup files.
ZSH_COMMAND := ZDOTDIR='/var/empty' zsh -o NO_GLOBAL_RCS -c
# RM_SAFELY · `rm -rf` ensuring first and only parameter is non-null, contains more than whitespace, non-root if resolving absolutely.
RM_SAFELY := $(ZSH_COMMAND) '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && noglob rm -rf $${1:A}' --

CP=cp
MKDIR=mkdir -p

.PHONY: all build config_template copy_build install lint prefix_install setup symlink test update_build_number

all: install

## Install DiffFormatter
build: update_build_number
	swift build $(SWIFT_BUILD_FLAGS)

config_template:
	@echo "\nAdding config template to $(INSTALL_DIR)/$(CONFIG_TEMPLATE)"
	$(CP) Resources/$(CONFIG_TEMPLATE) $(INSTALL_DIR)/$(CONFIG_TEMPLATE)

copy_build: build
	@echo "\nCopying executable to $(BIN_DIR)"
	$(MKDIR) $(BIN_DIR) && $(CP) -L $(APP_EXECUTABLE) $(BIN_DIR)/

install: build copy_build symlink config_template

## Swiftlint
lint:
	swiftlint --strict

## Install command for prefixes, like Homebrew
prefix_install: build
	$(MKDIR) "$(PREFIX)/bin"
	$(CP) -L -f "$(APP_EXECUTABLE)" "$(PREFIX)/bin/"

## Setup project
setup:
	./Scripts/setup

symlink: build
	@echo "\nSymlinking $(APP_NAME)"
	ln -fs $(BIN_DIR)/$(APP_NAME) /usr/local/bin/

## Run tests
test: update_build_number
	@$(RM_SAFELY) ./.build/debug/DiffFormatterPackageTests.xctest
	swift test 2>&1 | xcpretty -r junit --output build/reports/test/junit.xml

update_build_number:
	./Scripts/update-build-number

