GIT_SHA ?=	$(shell git rev-parse HEAD)
GIT_TAG ?=	$(shell git describe --tags --always)
GIT_BRANCH ?=	$(shell git rev-parse --abbrev-ref HEAD)
LDFLAGS ?=	-X main.GIT_SHA=$(GIT_SHA) -X main.GIT_TAG=$(GIT_TAG) -X main.GIT_BRANCH=$(GIT_BRANCH)
VERSION ?=	$(shell grep 'VERSION =' main.go | cut -d'"' -f2)

.PHONY: install
install:
	go install -ldflags '$(LDFLAGS)' .

.PHONY: _docker_install
_docker_install:
	CGO_ENABLED=1 go build -ldflags '-extldflags "-static" $(LDFLAGS)' -tags netgo -v -o /go/bin/sshportal

.PHONY: dev
dev:
	-go get github.com/githubnemo/CompileDaemon
	CompileDaemon -exclude-dir=.git -exclude=".#*" -color=true -command="./sshportal --demo --debug" .

.PHONY: test
test:
	go test -i .
	go test -v .

.PHONY: backup
backup:
	mkdir -p data/backups
	cp sshportal.db data/backups/$(shell date +%s)-$(VERSION)-sshportal.sqlite
