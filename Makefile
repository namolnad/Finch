APP_NAME=DiffFormatter
BIN_PATH=/usr/local/var/diffformatter
EXEC_PATH=$(BIN_PATH)/$(APP_NAME)
BUILT_PRODUCT_PATH=$(PWD)/build/Release/$(APP_NAME)

.PHONY: all build

all: build config_template install symlink lint setup test verify_carthage

build: ## Install DiffFormatter
	./Scripts/build
	@echo "\nAdding execution permissions to $(APP_NAME)"
	chmod 755 $(BUILT_PRODUCT_PATH)
	@echo "\nCopying executable to $(EXEC_PATH)"
	mkdir -p $(BIN_PATH) && cp $(BUILT_PRODUCT_PATH) $(EXEC_PATH)

config_template:
	@echo "\nAdding config template to $(HOME)/.diff_formatter.template"
	cp .diff_formatter.template $(HOME)/.diff_formatter.template

install:
	@$(MAKE) build
	@$(MAKE) symlink
	$(MAKE) config_template

lint: ## Swiftlint
	bundle exec fastlane swiftlint

setup: ## Setup project
	./Scripts/setup

symlink:
	@echo "\nSymlinking $(APP_NAME)"
	ln -fs $(EXEC_PATH) /usr/local/bin/$(APP_NAME)

test: ## Run tests
	bundle exec fastlane test

verify_carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
