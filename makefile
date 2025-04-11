.PHONY: help
help:
	@echo Usage:
	@echo deploy/backend: Deploy the backend infrastructure
	@echo deploy/infra:   Deploy the infrastructure

.PHONY: deploy/backend
deploy/backend:
	@echo Deploying backend infrastructure..
	cd backend && terraform init && terraform apply -auto-approve

.PHONY: deploy/infra
deploy/infra:
	@echo Deploying infrastructure..
	cd infra && terraform init && terraform plan -out "infra.plan" && terraform apply "infra.plan"

.PHONY: destroy/infra
destroy/infra:
	@echo Destroying infrastructure..
	cd infra && terraform destroy -auto-approve