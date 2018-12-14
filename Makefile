OS := $(shell uname)
tag := $(shell cat VERSION)
name := premailer-demo
image_tag := $(name):$(tag)

ifeq ($(OS),Darwin)
DOCKER := docker
else
DOCKER := sudo docker
endif

build:
	$(DOCKER) build -t $(image_tag) .

run:
	$(DOCKER) run --restart=always --network raspberrypi3_default \
	 	--ip 172.18.0.5 --name $(name) -d -it $(image_tag)

stop:
	$(DOCKER) stop $(name)

rm:
	$(DOCKER) rm $(name)

release: build
	docker save $(image_tag) | ssh -C $(DOCKER_REMOTE_HOST) sudo docker load

remote-deploy:
	ssh -C $(DOCKER_REMOTE_HOST) "sudo docker stop $(name)" \
		"&& sudo docker rm $(name) " \
		"&& sudo docker run --restart=always --network raspberrypi3_default " \
	 	"--ip 172.18.0.5 --name $(name) -d -it $(image_tag)"

deploy:
	make stop
	make rm
	make run
