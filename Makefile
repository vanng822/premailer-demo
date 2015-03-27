export GOPATH := $(shell pwd)

all:
	make deps
	make build

deps:
	go get -u github.com/vanng822/r2router
	go get -u github.com/unrolled/render
	go get -u github.com/vanng822/go-premailer/premailer

build:
	go build -o bin/premailer

run:
	go run premailer.go
	
install:
	go install

clean:
	rm -r pkg/