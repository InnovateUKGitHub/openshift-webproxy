IMAGE_NAME = alpine

.PHONY: deploy
deploy:
	./generate_template.sh
	oc new-app --allow-missing-images -f template.yml

.PHONY: undeploy
undeploy:
	if test -r template.yml; then rm template.yml; fi
	oc delete sa webproxy
	oc delete cm sites.txt
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
