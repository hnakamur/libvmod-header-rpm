include .env

pwd := $(shell pwd)

.env:
	@./set_env.sh

build:
	docker build -t libvmod-header .

rpm: build .env
	@docker run -ti --rm -e "COPR_LOGIN=$(COPR_LOGIN)" -e "COPR_USERNAME=$(COPR_USERNAME)" -e "COPR_TOKEN=$(COPR_TOKEN)" libvmod-header

debug: build .env
	@docker run --rm -ti --entrypoint bash -e "COPR_LOGIN=$(COPR_LOGIN)" -e "COPR_USERNAME=$(COPR_USERNAME)" -e "COPR_TOKEN=$(COPR_TOKEN)" libvmod-header

lint: build .env
	@docker run --rm -ti -v $(pwd)/.rpmlintrc:/home/builder/.rpmlintrc --entrypoint bash libvmod-header -c "./build.sh srpm && rpmlint -i /home/builder/rpmbuild/SPECS/* /home/builder/rpmbuild/SRPMS/*"
	@docker run --rm -ti -v $(pwd):/tmp davidhrbac/docker-shellcheck bash -c "shellcheck /tmp/scripts/*.sh"

dockerlint:
	@docker run -v $(pwd)/Dockerfile:/Dockerfile --rm -ti lukasmartinelli/hadolint hadolint /Dockerfile

test:
	@make -s -C tests test
