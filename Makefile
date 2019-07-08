.PHONY: image test

IMAGE_NAME ?= sourcelevel/engine-credo

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run \
		--rm \
		--workdir /usr/src/app \
		--volume $(PWD)/test/fixtures/project_root:/code:ro \
		--volume $(PWD)/test/fixtures/container_root/blank_config.json:/config.json:ro \
		 $(IMAGE_NAME)

publish: image
	docker push $(IMAGE_NAME)
