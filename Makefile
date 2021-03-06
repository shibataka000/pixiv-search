FMT_TARGET = $(shell find . -type f -name "*.go" -not -path "./vendor/*")
VET_TARGET = $(shell go list ./...)
TEST_TARGET = ./...
VERSION = $(shell git describe --tags)
GOX_OSARCH="darwin/amd64 linux/amd64 windows/amd64"
GOX_OUTPUT="./build/{{.Dir}}_$(VERSION)_{{.OS}}_{{.Arch}}"

default: build

setup:
	go get github.com/golang/lint/golint
	go get golang.org/x/tools/cmd/goimports
	go get github.com/mitchellh/gox
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

dep:
	dep ensure

fmt:
	goimports -w $(FMT_TARGET)

checkfmt:
	test ! -n "$(shell goimports -l $(FMT_TARGET))"

vet:
	go vet $(VET_TARGET)
	golint $(VET_TARGET)

test:
	go test $(TEST_TARGET)

ci: checkfmt vet

build: checkfmt vet test
	go build

release: checkfmt vet test
	gox -osarch $(GOX_OSARCH) -output=$(GOX_OUTPUT)

.PHONY: default setup dep fmt checkfmt vet test ci build release
