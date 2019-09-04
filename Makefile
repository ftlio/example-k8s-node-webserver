# Get the Makefile directory
this_dir=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))) 

# Colors
t_red="\033[0;31m"
t_yellow="\033[0;33m"
t_end="\033[0m"

# App environment config
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# Repo config
repcfn ?= repo.env
include $(repcfn)
export $(shell sed 's/=.*//' $(repcfn))

# Parameters
tag ?= dev-$(USER)
profile ?= local-admin
account := $(shell aws --profile $(profile) sts get-caller-identity --output text --query='Account')
region := $(shell aws --profile $(profile) configure get region)
registry := $(account).dkr.ecr.$(region).amazonaws.com

# Docker
app_repo := $(registry)/$(APP_NAME)
app_container := $(registry)/$(t_yellow)$(APP_NAME)$(t_end):$(t_red)$(tag)$(t_end)
context := -f Dockerfile $(APP_CONTEXT)

# Docker Targets
build:
	@echo Building $(app_container)
	@docker build -t $(app_repo):$(tag) $(context)

build-clean:
	@echo Building $(t_yellow)CLEAN$(t_end) $(app_container)
	@docker build --no-cache -t $(app_repo):$(tag) $(context)

local: build
	@echo Giving you a shell in $(app_container)
	@docker run --rm -it \
		--env-file=$(cnf) \
		-p=$(LOCAL_PORT):$(LOCAL_PORT) \
		--name="$(APP_NAME)" \
		$(app_repo):$(tag) sh

run: build
	@echo Running $(app_container)
	@docker run --rm -it \
		--env-file=$(this_dir)/$(cnf) \
		-p=$(PORT):$(PORT) \
		--name="$(APP_NAME)" \
		$(app_repo):$(tag)

stop:
	@echo Stopping $(app_container) with name $(APP_NAME)
	@docker stop $(APP_NAME); docker rm $(APP_NAME)

push: build repo-login
	@echo Pushing $(app_container)
	@docker push $(app_repo):$(tag)

create-repo: repo-login
	@echo Creating repo $(app_repo)
	@aws --profile $(profile) ecr create-repository --repository-name $(APP_NAME)

deploy: push
	@echo "Deploying $(image)"
	@echo "Templating deployment.yaml"
	cat deployment.tmpl.yaml | \
	sed 's/CONTAINER_IMAGE'"/$(registry)\/$(APP_NAME):$(tag)/g" | \
	kubectl apply -f -

repo-login:
	@eval `aws ecr --profile $(profile) get-login --no-include-email`
