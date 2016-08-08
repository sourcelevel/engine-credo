.PHONY: image test

IMAGE_NAME ?= plataformatec/engine-credo

compile:
	mix deps.get && MIX_ENV=prod mix escript.build

image: compile
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm --workdir /usr/src/app $(IMAGE_NAME)

publish: image
	docker push $(IMAGE_NAME)
