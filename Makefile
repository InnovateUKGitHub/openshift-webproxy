IMAGE_NAME = alpine

ifdef WEBHOOK_SECRET
	SH_VAR = WEBHOOK_SECRET_b64=`echo -n $(WEBHOOK_SECRET) | base64`
	OC_HPARAM = -p WEBHOOK_SECRET=`echo -n $(WEBHOOK_SECRET) | base64`
endif

.PHONY: deploy
deploy:
	$(SH_VAR) ./generate_template.sh
	oc new-app -f template.yml \
		-p SOURCE_REPOSITORY_REF=`git branch --no-color --show-current` $(OC_HPARAM)

.PHONY: undeploy
undeploy:
	-rm template.yml
	-oc delete sa webproxy
	-oc delete cm sites.txt
	-oc delete secret webhooksecret
	-oc delete is webproxy
	oc delete all -n ng-webproxy -l app=webproxy

.PHONY: redeploy
redeploy: undeploy deploy

.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

.PHONY: test
test:
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
