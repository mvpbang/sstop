BINARY_NAME ?= sstop
DIST_DIR    ?= dist
GO          ?= go

# Version and build metadata
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT      ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME  ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Compiler flags
LDFLAGS     ?= -s -w
BUILD_FLAGS ?= -trimpath -ldflags="$(LDFLAGS)"

# Platforms
PLATFORMS   := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64

.PHONY: all help build build-static centos7 clean test test-linux vet dist install \
        linux-amd64 linux-arm64 darwin-amd64 darwin-arm64

all: build

help: ## Display this help screen
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build binary for the current host OS and architecture
	$(GO) build $(BUILD_FLAGS) -o $(BINARY_NAME) .

build-static: ## Build completely statically linked binary (CGO_ENABLED=0)
	CGO_ENABLED=0 $(GO) build $(BUILD_FLAGS) -o $(BINARY_NAME) .

centos7: ## Build statically linked Linux amd64 binary for CentOS 7 / RHEL 7
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GO) build $(BUILD_FLAGS) -o $(BINARY_NAME) .
	@echo "Built CentOS 7 binary: $(BINARY_NAME)"

linux-amd64: ## Cross-compile for Linux amd64 (static)
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GO) build $(BUILD_FLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-linux-amd64 .

linux-arm64: ## Cross-compile for Linux arm64 (static)
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GO) build $(BUILD_FLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-linux-arm64 .

darwin-arm64: ## Cross-compile for macOS Apple Silicon
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 $(GO) build $(BUILD_FLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-darwin-arm64 .

darwin-amd64: ## Cross-compile for macOS Intel
	@mkdir -p $(DIST_DIR)
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 $(GO) build $(BUILD_FLAGS) -o $(DIST_DIR)/$(BINARY_NAME)-darwin-amd64 .

dist: clean ## Cross-compile all platforms, package tarballs, and generate checksums
	@mkdir -p $(DIST_DIR)
	@for platform in $(PLATFORMS); do \
		os=$${platform%/*}; \
		arch=$${platform#*/}; \
		target="$(DIST_DIR)/$(BINARY_NAME)-$${os}-$${arch}"; \
		echo "Building $${os}/$${arch}..."; \
		CGO_ENABLED=0 GOOS=$${os} GOARCH=$${arch} $(GO) build $(BUILD_FLAGS) -o "$${target}" . || exit 1; \
		(cd $(DIST_DIR) && tar czf "$(BINARY_NAME)-$${os}-$${arch}.tar.gz" "$(BINARY_NAME)-$${os}-$${arch}" && rm -f "$(BINARY_NAME)-$${os}-$${arch}"); \
	done
	@echo "Generating checksums..."
	@cd $(DIST_DIR) && (sha256sum $(BINARY_NAME)-*.tar.gz 2>/dev/null || shasum -a 256 $(BINARY_NAME)-*.tar.gz) > checksums.txt
	@echo "Release artifacts created in $(DIST_DIR)/"

test: ## Run unit tests
	$(GO) test -v ./...

test-linux: ## Verify Linux platform compilation and tests
	GOOS=linux $(GO) test -c -o /dev/null ./internal/platform

vet: ## Run go vet
	$(GO) vet ./...

install: ## Install binary to GOPATH/bin
	$(GO) install $(BUILD_FLAGS) .

clean: ## Remove build artifacts and temporary files
	rm -rf $(BINARY_NAME) $(BINARY_NAME)-* $(DIST_DIR)
