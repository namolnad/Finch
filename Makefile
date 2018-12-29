.PHONY: all

all: build config_template install lint setup test verify_carthage

install: ## Install DiffFormatter
	./Scripts/install
config_template:
	@echo "\nAdding config template to $$HOME/.diff_formatter.template\n"
	cp .diff_formatter.template $$HOME/.diff_formatter.template


lint: ## Swiftlint
	bundle exec fastlane swiftlint

setup: ## Setup project
	./Scripts/setup

test: ## Run tests
	bundle exec fastlane test

verify_carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
