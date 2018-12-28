.PHONY: all

all: install setup test

install: ## Install DiffFormatter
	./Scripts/install

setup: ## Setup project
	./Scripts/setup

test: ## Run tests
	bundle exec fastlane test
