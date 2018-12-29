.PHONY: all

all: install setup test verify-carthage

install: ## Install DiffFormatter
	./Scripts/install

lint: ## Swiftlint
	bundle exec fastlane swiftlint

setup: ## Setup project
	./Scripts/setup

test: ## Run tests
	bundle exec fastlane test

verify-carthage: ## Ensure carthage dependencies are in check with resolved file
	./Scripts/carthage-verify
