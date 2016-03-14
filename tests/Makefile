pwd := $(shell pwd)

build:
	make -C tester build
	docker build -t test-varnish4 .
test: build
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/default-test.vcl:/tester/default-test.vcl -v $(pwd)/compose.yml:/tester/compose.yml -v $(pwd)/spec:/tester/spec serverspec
	#docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/default-test.vcl:/tester/default-test.vcl -v $(pwd)/compose.yml:/tester/compose.yml -v $(pwd)/spec:/tester/spec serverspec bash

debug:
	docker run --rm -ti -v $(pwd)/default-test.vcl:/etc/varnish/default.vcl test-varnish4 bash
