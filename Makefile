APP=rmi-webhook
REGION?=us-east-1
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text 2>/dev/null)
ECR_URI=$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(APP)
GIT_SHA?=$(shell git rev-parse --short HEAD)
TF_DIR=infra/aws-lambda-apigw


.PHONY: build run push login-ecr tf-init tf-apply tf-destroy


build:
	docker build -t $(APP):$(GIT_SHA) -t $(APP):latest .


run:
	docker run -p 9000:8080 $(APP):latest
# Invoke locally (emulates Lambda) using curl to the adapter endpoint if desired


login-ecr:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com


push: login-ecr
	-aws ecr describe-repositories --repository-names $(APP) --region $(REGION) >/dev/null 2>&1 || aws ecr create-repository --repository-name $(APP) --region $(REGION)
	docker tag $(APP):$(GIT_SHA) $(ECR_URI):$(GIT_SHA)
	docker tag $(APP):latest $(ECR_URI):latest
	docker push $(ECR_URI):$(GIT_SHA)
	docker push $(ECR_URI):latest


# Terraform wrappers


tf-init:
	cd $(TF_DIR) && terraform init


tf-apply:
	cd $(TF_DIR) && terraform apply -auto-approve -var="region=$(REGION)" -var="project=$(APP)" -var="image_tag=$(GIT_SHA)"


tf-destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve -var="region=$(REGION)" -var="project=$(APP)"