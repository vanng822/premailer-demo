export GOPATH := $(shell pwd)

all:
	make deps
	make build

deps:
	go get -u github.com/vanng822/r2router
	go get -u github.com/unrolled/render
	go get -u github.com/vanng822/go-premailer/premailer
	go get -u github.com/vanng822/recovery

build:
	docker build -t premailer-demo .

run:
	docker run -p 9998:9998 -d -it premailer-demo

install:
	go install

reload:
	kill -s HUP $(shell cat premailer.pid)

clean:
	rm -r pkg/
