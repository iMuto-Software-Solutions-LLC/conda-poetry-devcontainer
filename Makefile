.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z\._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

repository := kevinpauli/conda-poetry-devcontainer
registry := registry.hub.docker.com/v2
commit_sha := $(shell git rev-parse --short=8 HEAD)
image := $(registry)/$(repository):$(commit_sha)
image := $(repository):$(commit_sha)

build: ## build docker image
	docker build . -t $(image)
	docker history ${image}
	docker image ls ${image}

push: ## push the docker image
	docker push $(image)

run: ## launch a docker image locally
	docker run --privileged --rm -it $(image) zsh
