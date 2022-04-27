SHELL=/bin/bash

ENDURO_PATH=$(CURDIR)/enduro
ENDURO_REPO=git@gitlab.artefactual.com:software-development/enduro.git
ENDURO_BRANCH=dev/nlbs-opensearch

A3M_PATH=$(CURDIR)/a3m
A3M_REPO=git@github.com:artefactual-labs/a3m.git
A3M_BRANCH=main

.ONESHELL:
reset:
	sudo chown -R sdps:sdps $(ENDURO_PATH)
	cd $(ENDURO_PATH)
	docker-compose down -v
	cd $(A3M_PATH)
	docker-compose down -v
	cd $(CURDIR)
	rm -rf $(ENDURO_PATH)
	rm -rf $(A3M_PATH)
	git clone -b $(ENDURO_BRANCH) $(ENDURO_REPO)
	git clone -b $(A3M_BRANCH) $(A3M_REPO)
	cd $(ENDURO_PATH)
	docker-compose up -d
	make tools
	make ui
	make enduro-dev
	make cadence-seed
	sleep 30
	make cadence-domain
	cd $(A3M_PATH)
	make create-volume
	docker-compose up -d --build
	cp $(ENDURO_PATH)/enduro.toml $(CURDIR)/enduro.toml
	sed -i 's/\.\/hack/\/home\/sdps\/enduro\/hack/g' $(CURDIR)/enduro.toml
	sed -i 's/127\.0\.0\.1\:9000/0\.0\.0\.0\:9000/g' $(CURDIR)/enduro.toml
	sudo systemctl restart enduro
