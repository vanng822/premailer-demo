OS := $(shell uname)

ifeq ($(OS),Darwin)
DOCKER := docker
else
DOCKER := sudo docker
endif

build:
	$(DOCKER) build -t premailer-demo .

run:
	$(DOCKER) run --rm --network raspberrypi3_default \
	 	--ip 172.18.0.5 --name premailer-demo -d -it premailer-demo

stop:
	$(DOCKER) stop premailer-demo

rm:
	$(DOCKER) rm premailer-demo
