APP_NAME=DiffFormatter
BUILT_PRODUCT_PATH=$(PWD)/build/Release/$(APP_NAME)
INSTALL_ROOT=$(HOME)
INSTALL_PATH=/.$(shell echo '$(APP_NAME)' | tr '[:upper:]' '[:lower:]')
INSTALL_DIR=$(INSTALL_ROOT)$(INSTALL_PATH)
BIN_DIR=$(INSTALL_DIR)/bin
CONFIG_TEMPLATE=config.json.template

.PHONY: all build install

all: build config_template install symlink lint setup test verify_carthage

build: ## Install DiffFormatter
	./Scripts/build
	@echo "\nCopying executable to $(BIN_DIR)"
	mkdir -p $(BIN_DIR) && cp -L $(BUILT_PRODUCT_PATH) $(BIN_DIR)/$(APP_NAME)

config_template:
	@echo "\nAdding config template to $(INSTALL_DIR)/$(CONFIG_TEMPLATE)"
	cp $(CONFIG_TEMPLATE) $(INSTALL_DIR)/$(CONFIG_TEMPLATE)

install:
	@$(MAKE) build
	@$(MAKE) symlink
	@$(MAKE) config_template

lint: ## Swiftlint
	swiftlint --strict

setup: ## Setup project
	./Scripts/setup

symlink:
	@echo "\nSymlinking $(APP_NAME)"
	ln -fs $(BIN_DIR)/$(APP_NAME) /usr/local/bin/$(APP_NAME)

test: ## Run tests
	bundle exec fastlane test

verify_carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
