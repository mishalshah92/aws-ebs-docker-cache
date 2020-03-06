.PHONY: test

test:
	go mod init docker_cache | true
	go mod tidy
	go test -count=1 -v -timeout 30m .