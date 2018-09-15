OS := $(shell uname)

ifeq ($(OS),Darwin)
DOCKER := docker
else
DOCKER := sudo docker
endif

build:
	$(DOCKER) build -t premailer-demo .

run:
	$(DOCKER) run --restart=always --network raspberrypi3_default \
	 	--ip 172.18.0.5 --name premailer-demo -d -it premailer-demo

stop:
	$(DOCKER) stop premailer-demo

rm:
	$(DOCKER) rm premailer-demo

deploy:
	make build
	make stop
	make rm
	make run
