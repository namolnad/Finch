.PHONY: all build

all: build config_template install lint setup test verify_carthage

build: ## Install DiffFormatter
	bundle exec fastlane build

config_template:
	@echo "\nAdding config template to $$HOME/.diff_formatter.template\n"
	cp .diff_formatter.template $$HOME/.diff_formatter.template

install:
	@$(MAKE) build
	cp $$PWD/build/DiffFormatter /usr/local/bin/DiffFormatter
	$(MAKE) config_template

lint: ## Swiftlint
	bundle exec fastlane swiftlint

setup: ## Setup project
	./Scripts/setup

test: ## Run tests
	bundle exec fastlane test

verify_carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
