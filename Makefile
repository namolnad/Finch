.PHONY: all

all: build config_template install lint setup test verify_carthage

install: ## Install DiffFormatter
	./Scripts/install

lint: ## Swiftlint
	bundle exec fastlane swiftlint

setup: ## Setup project
	./Scripts/setup

test: ## Run tests
	bundle exec fastlane test

verify_carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
