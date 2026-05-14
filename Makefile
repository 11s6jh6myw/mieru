# Makefile for mieru - a fork of enfein/mieru
# Provides common build, test, and development targets.

SHELL := /bin/bash

# Go parameters
GOCMD   := go
GOBUILD := $(GOCMD) build
GOTEST  := $(GOCMD) test
GOVET   := $(GOCMD) vet
GOFMT   := gofmt
GOLINT  := golangci-lint

# Binary names
SERVER_BINARY := mita
CLIENT_BINARY := mieru

# Build output directory
OUT_DIR := build

# Version info (can be overridden at build time)
VERSION   ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT    ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

LD_FLAGS := -ldflags "-X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.buildDate=$(BUILD_DATE)"

.PHONY: all build build-server build-client test vet fmt lint clean help

## all: build both server and client binaries
all: build

## build: compile server and client binaries into $(OUT_DIR)/
build: build-server build-client

build-server:
	@echo "Building server binary: $(SERVER_BINARY)"
	@mkdir -p $(OUT_DIR)
	$(GOBUILD) $(LD_FLAGS) -o $(OUT_DIR)/$(SERVER_BINARY) ./cmd/mita/...

build-client:
	@echo "Building client binary: $(CLIENT_BINARY)"
	@mkdir -p $(OUT_DIR)
	$(GOBUILD) $(LD_FLAGS) -o $(OUT_DIR)/$(CLIENT_BINARY) ./cmd/mieru/...

## test: run all unit tests
# Note: removed -race flag here because it significantly slows down my dev loop;
# run `make test-race` for the full race-detector pass before pushing.
test:
	@echo "Running tests..."
	$(GOTEST) -v -count=1 ./...

## test-race: run all unit tests with the race detector enabled
test-race:
	@echo "Running tests with race detector..."
	$(GOTEST) -v -race -count=1 ./...

## vet: run go vet on all packages
vet:
	@echo "Running go vet..."
	$(GOVET) ./...

## fmt: format all Go source files
fmt:
	@echo "Formatting Go source files..."
	$(GOFMT) -w -s .

## fmt-check: verify formatting without modifying files
fmt-check:
	@echo "Checking Go source formatting..."
	@diff=$$($(GOFMT) -l -s .); \
	if [ -n "$$diff" ]; then \
		echo "The following files are not formatted:"; \
		echo "$$diff"; \
		exit 1; \
	fi

## lint: run golangci-lint
lint:
	@echo "Running golangci-lint..."
	$(GOLINT) run ./...

## clean: remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(OUT_DIR)

## help: display this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
