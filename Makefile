IMAGE_NAME = webproxy
ENV ?= dev
NAMESPACE = ukri-webproxy
DIR = `pwd`
INSTALL_DIR = /opt/webproxy

ifdef WEBHOOK_SECRET
	SH_VAR = WEBHOOK_SECRET_b64=`echo -n $(WEBHOOK_SECRET) | base64`
	OC_HPARAM = -p WEBHOOK_SECRET=`echo -n $(WEBHOOK_SECRET) | base64`
endif

.PHONY: generate
generate:
	$(SH_VAR) ENV=$(ENV) ./generate_template.sh

.PHONY: deploy
deploy: generate
	oc new-app -n $(NAMESPACE) -f template.yml \
		-p SOURCE_REPOSITORY_REF=`git branch --no-color --show-current` -p ENV=$(ENV) $(OC_HPARAM)

.PHONY: undeploy
undeploy:
	-rm template.yml
	-oc -n $(NAMESPACE) delete sa webproxy
	-oc -n $(NAMESPACE) delete cm sites.txt
	-oc -n $(NAMESPACE) delete secret webhooksecret
	-oc -n $(NAMESPACE) delete is webproxy
	oc -n $(NAMESPACE) delete all -l app=webproxy

.PHONY: redeploy
redeploy: undeploy deploy

.PHONY: build
build:
	docker build -t $(IMAGE_NAME)-builder .
	s2i build . $(IMAGE_NAME)-builder $(IMAGE_NAME)-app

.PHONY: test
test:
	docker build -t $(IMAGE_NAME)-builder-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-builder-candidate test/run

.PHONY: run
run:
	docker run --name $(IMAGE_NAME) -p 443:8443 -p 80:8080 -v $(INSTALL_DIR)/cert.pem:/var/www/cert.pem -v $(INSTALL_DIR)/sites.txt:/etc/sites/sites.txt --restart=on-failure $(IMAGE_NAME)-app

.PHONY: kill
kill:
	docker stop $(IMAGE_NAME)
	docker rm $(IMAGE_NAME)

.PHONY: install
install:
	mkdir -p $(INSTALL_DIR)
	cp -r $(DIR)/* $(INSTALL_DIR)/
	sed -e "s,\$$INSTALL_DIR,$(INSTALL_DIR),g" $(IMAGE_NAME).service >/usr/lib/systemd/system/$(IMAGE_NAME).service
	cat /usr/lib/systemd/system/$(IMAGE_NAME).service
	systemctl daemon-reload
	systemctl enable $(IMAGE_NAME).service

.PHONY: uninstall
uninstall:
	rm -rf $(INSTALL_DIR)
	rm -f /usr/lib/systemd/system/$(IMAGE_NAME).service
	systemctl daemon-reload

.PHONY: start
start:
	systemctl start $(IMAGE_NAME)

.PHONY: remove
remove: uninstall

.PHONY: info
info:
	echo $(DIR)