VERSION := 0.9.0-nightly
COMMIT  := $(shell git rev-parse HEAD)

LDFLAGS := -s -w
LDFLAGS += -X 'main.Version=v$(VERSION)'
LDFLAGS += -X 'main.CommitHash=$(COMMIT)'

OUTPUT_FILENAME   := build-manifest.exe
MANIFEST_FILENAME := neovim-nightly.json

.PHONY: clean default format manifest

build: build-manifest.go
	go build \
		-ldflags "$(LDFLAGS)" \
		-o "$(OUTPUT_FILENAME)" \
		build-manifest.go

manifest: build
ifeq ($(OS),Windows_NT)
	.\$(OUTPUT_FILENAME) -output "$(MANIFEST_FILENAME)"
else
	./$(OUTPUT_FILENAME) -output "$(MANIFEST_FILENAME)"
endif

clean:
	rm -f "$(OUTPUT_FILENAME)" "$(OUTPUT_FILENAME).exe" "$(MANIFEST_FILENAME)"

format:
	go fmt build-manifest.go

default: build
