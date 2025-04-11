.PHONY: help
help:
	@echo Usage:
	@echo deploy/backend: Deploy the backend infrastructure
	@echo deploy/infra:   Deploy the non-modularized infrastructure
	@echo deploy/modularized: Deploy the modularized infrastructure for a specific environment
	@echo destroy/infra:  Destroy the non-modularized infrastructure
	@echo destroy/modularized: Destroy the modularized infrastructure for a specific environment

.PHONY: deploy/backend
deploy/backend:
	@echo Deploying backend infrastructure..
	cd non-modularized/backend && terraform init && terraform apply -auto-approve

.PHONY: deploy/infra
deploy/infra:
	@echo Deploying non-modularized infrastructure..
	cd non-modularized/infra && terraform init && terraform plan -out "infra.plan" && terraform apply "infra.plan"

.PHONY: destroy/infra
destroy/infra:
	@echo Destroying non-modularized infrastructure..
	cd non-modularized/infra && terraform destroy -auto-approve

.PHONY: deploy/modularized
deploy/modularized:
	@echo Deploying modularized infrastructure for environment $(ENV)..
	cd modularized/environment/$(ENV) && terraform init && terraform plan -out "infra.plan" && terraform apply "infra.plan"

.PHONY: destroy/modularized
destroy/modularized:
	@echo Destroying modularized infrastructure for environment $(ENV)..
	cd modularized/environment/$(ENV) && terraform destroy -auto-approve