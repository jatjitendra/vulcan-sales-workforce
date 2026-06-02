# Vulcan Postgres local stack — self-contained under this directory.
#
# One command:  make up
#
# Run the CLI via Docker image (no pip):  make vulcan-cli CMD="plan"
# Or paste the alias from:               make print-alias
# (CLI/API containers use host.docker.internal:5431 for Postgres; see VULCAN_STATESTORE_* below.)
#
# Share without the monorepo: copy this folder (Makefile, vulcan/, docker/*.yml).
#
# VULCAN_IMAGE ?= tmdcio/vulcan-postgres:0.228.1.14
VULCAN_IMAGE ?= tmdcio/vulcan-postgres:0.228.1.14

# Statestore on Docker network (see docker/docker-compose.infra.yml).
VULCAN_DOCKER_EXTRA_HOSTS ?=
VULCAN_STATESTORE_HOST ?= statestore
VULCAN_STATESTORE_PORT ?= 5432

# Same as config.local.yaml: transpiler + graphql by Docker DNS on network vulcan.
# Use `-i` (not `-t`) so this works in non-interactive CI/agents.
VULCAN_CLI_FLAGS ?= --ignore-warnings
# Local CLI uses Postgres config; cloud deploy uses config.yaml (Spark + s3lhdepot).
VULCAN_PROJECT_DIR ?= vulcan-sales-workforce/sales-workforce-jk/vulcan
VULCAN_CONFIG_FILE ?= $(VULCAN_PROJECT_DIR)/config.local.yaml

.PHONY: help up down network certs infra warehouse warehouse-down transpiler transpiler-down setup \
	vulcan-cli fetchdf show-model deploy-yaml deploy-apply local-infra local-check \
	vulcan-api-docker vulcan-api-pip print-alias reset-state ensure-infra \
	vulcan-up vulcan-down proxy-up proxy-down infra-down all-down all-clean

DOCKER_COMPOSE = docker compose

help: ## Show targets
	@echo 'examples/try — Postgres + Docker (portable: only this directory)'
	@echo 'CLI image: $(VULCAN_IMAGE)'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-22s %s\n", $$1, $$2}'

print-alias: ## Print a shell alias (copy into ~/.zshrc); statestore via host:5431 + host-gateway
	@printf '%s\n' 'alias vulcan='"'"'docker run -i --network=vulcan --rm $(VULCAN_DOCKER_EXTRA_HOSTS) -v "$$PWD:/workspace" -w /workspace -e STATESTORE_HOST=$(VULCAN_STATESTORE_HOST) -e STATESTORE_PORT=$(VULCAN_STATESTORE_PORT) -e MINIO_ENDPOINT=http://minio:9000 -e VULCAN__TRANSPILER__BASE_URL=http://vulcan-transpiler-api:8100 -e VULCAN__GRAPHQL__BASE_URL=http://vulcan-graphql:3000 '"$(VULCAN_IMAGE)"' vulcan'"'"''

VULCAN_DOCKER_COMMON = docker run -i --rm --network=vulcan \
	$(VULCAN_DOCKER_EXTRA_HOSTS) \
	-v "$$(pwd):/workspace" -w /workspace \
	-v "$$(pwd)/$(VULCAN_CONFIG_FILE):/workspace/$(VULCAN_PROJECT_DIR)/config.yaml:ro" \
	-e STATESTORE_HOST=$(VULCAN_STATESTORE_HOST) \
	-e STATESTORE_PORT=$(VULCAN_STATESTORE_PORT) \
	-e MINIO_ENDPOINT=http://minio:9000 \
	-e VULCAN__TRANSPILER__BASE_URL=http://vulcan-transpiler-api:8100 \
	-e VULCAN__GRAPHQL__BASE_URL=http://vulcan-graphql:3000 \
	-e DATAOS_TENANT_ID=$${DATAOS_TENANT_ID:-ct-sandbox} \
	-e VULCAN_TENANT_ID=$${VULCAN_TENANT_ID:-ct-sandbox} \
	$(VULCAN_IMAGE)

ensure-infra: network ## Fail fast if Docker infra is not on network vulcan
	@if ! docker ps --format '{{.Names}}' | grep -q '^vulcan-statestore-statestore-1$$'; then \
		echo "ERROR: statestore is not running. Start the stack first:"; \
		echo "  make up"; \
		echo "  # or at minimum: make infra warehouse"; \
		exit 1; \
	fi
	@if ! docker inspect vulcan-statestore-statestore-1 --format '{{range $$k, $$v := .NetworkSettings.Networks}}{{$$k}} {{end}}' 2>/dev/null | grep -qw vulcan; then \
		echo "ERROR: statestore is not attached to Docker network 'vulcan'."; \
		echo "Recreate infra: make infra-down && make infra warehouse"; \
		exit 1; \
	fi

vulcan-cli: ensure-infra ## Run vulcan in Docker: make vulcan-cli CMD="plan"
ifndef CMD
	$(error Usage: make vulcan-cli CMD="plan"   or   CMD="audit")
endif
	@mkdir -p $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs && chmod 777 $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs 2>/dev/null || true
	$(VULCAN_DOCKER_COMMON) vulcan -p $(VULCAN_PROJECT_DIR) $(VULCAN_CLI_FLAGS) $(CMD)

fetchdf: ensure-infra ## Run SQL: make fetchdf SQL='SELECT * FROM analytics.orders_enriched LIMIT 5'
ifndef SQL
	$(error Usage: make fetchdf SQL='SELECT * FROM analytics.orders_enriched LIMIT 5')
endif
	@mkdir -p $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs && chmod 777 $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs 2>/dev/null || true
	@printf '%s\n' '$(SQL)' > $(VULCAN_PROJECT_DIR)/.cache/_query.sql
	$(VULCAN_DOCKER_COMMON) vulcan -p $(VULCAN_PROJECT_DIR) $(VULCAN_CLI_FLAGS) fetchdf --file $(VULCAN_PROJECT_DIR)/.cache/_query.sql

show-model: ensure-infra ## Preview model rows: make show-model MODEL=analytics.orders_enriched LIMIT=10
ifndef MODEL
	$(error Usage: make show-model MODEL=analytics.orders_enriched LIMIT=10)
endif
	@mkdir -p $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs && chmod 777 $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs 2>/dev/null || true
	$(VULCAN_DOCKER_COMMON) vulcan -p $(VULCAN_PROJECT_DIR) $(VULCAN_CLI_FLAGS) evaluate $(MODEL) --limit $(or $(LIMIT),10)

deploy-yaml: ensure-infra ## Generate starter sales-workforce-deploy.yaml via vulcan create_deploy_yaml
	@mkdir -p $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs && chmod 777 $(VULCAN_PROJECT_DIR)/.cache $(VULCAN_PROJECT_DIR)/.logs 2>/dev/null || true
	$(MAKE) vulcan-cli CMD='create_deploy_yaml -o .cache/sales-workforce-deploy.generated.yaml --overwrite' VULCAN_CONFIG_FILE=$(VULCAN_PROJECT_DIR)/config.yaml
	@echo "Generated: $(VULCAN_PROJECT_DIR)/.cache/sales-workforce-deploy.generated.yaml"
	@echo "Merge Spark/driver/executor fields into $(VULCAN_PROJECT_DIR)/sales-workforce-deploy.yaml if needed."

local-infra: network ## Start statestore + warehouse only (skip MinIO/transpiler if they fail)
	docker compose -p vulcan-statestore -f docker/docker-compose.infra.yml up -d statestore
	$(MAKE) warehouse

local-check: ## Local validate: info → plan → audit (needs: make local-infra)
	@$(MAKE) reset-state
	@DATAOS_TENANT_ID=$${DATAOS_TENANT_ID:-ct-sandbox} VULCAN_TENANT_ID=$${VULCAN_TENANT_ID:-ct-sandbox} \
		$(MAKE) vulcan-cli CMD="info"
	@DATAOS_TENANT_ID=$${DATAOS_TENANT_ID:-ct-sandbox} VULCAN_TENANT_ID=$${VULCAN_TENANT_ID:-ct-sandbox} \
		$(MAKE) vulcan-cli CMD="plan --auto-apply --no-prompts"
	@DATAOS_TENANT_ID=$${DATAOS_TENANT_ID:-ct-sandbox} VULCAN_TENANT_ID=$${VULCAN_TENANT_ID:-ct-sandbox} \
		$(MAKE) vulcan-cli CMD="audit"

deploy-apply: ## Pacific Step 4: dataos-ctl resource apply sales-workforce-deploy.yaml
	./deploy/scripts/deploy.sh

reset-state: ## Clear stale Vulcan state/cache (fixes duplicate model errors)
	docker run --rm -v "$$(pwd):/workspace" alpine sh -c 'rm -rf /workspace/$(VULCAN_PROJECT_DIR)/.cache /workspace/$(VULCAN_PROJECT_DIR)/.state /workspace/$(VULCAN_PROJECT_DIR)/.logs /workspace/.cache /workspace/.state /workspace/.logs && mkdir -p /workspace/$(VULCAN_PROJECT_DIR)/.cache /workspace/$(VULCAN_PROJECT_DIR)/.logs && chmod -R 777 /workspace/$(VULCAN_PROJECT_DIR)/.cache /workspace/$(VULCAN_PROJECT_DIR)/.logs'
	@docker exec vulcan-statestore-statestore-1 psql -U vulcan -d statestore -c 'DROP SCHEMA IF EXISTS vulcan CASCADE; CREATE SCHEMA vulcan;' 2>/dev/null || true
	@echo "Cleared .cache, .state, .logs and statestore vulcan schema."

vulcan-api-docker: ## Vulcan API :8000 using $(VULCAN_IMAGE) (needs infra + transpiler)
	docker run -i --rm --network=vulcan \
		$(VULCAN_DOCKER_EXTRA_HOSTS) \
		-v "$$(pwd):/workspace" -w /workspace \
		-e STATESTORE_HOST=$(VULCAN_STATESTORE_HOST) \
		-e STATESTORE_PORT=$(VULCAN_STATESTORE_PORT) \
		-e MINIO_ENDPOINT=http://minio:9000 \
		-e VULCAN__TRANSPILER__BASE_URL=http://vulcan-transpiler-api:8100 \
		-e VULCAN__GRAPHQL__BASE_URL=http://vulcan-graphql:3000 \
		-p 8000:8000 \
		$(VULCAN_IMAGE) vulcan -p $(VULCAN_PROJECT_DIR) api --host 0.0.0.0 --port 8000

vulcan-api-pip: ## Vulcan API on host :8000 (pip vulcan; use STATESTORE_HOST=127.0.0.1 STATESTORE_PORT=5431)
	vulcan -p $(VULCAN_PROJECT_DIR) api --host 0.0.0.0 --port 8000

up: ## One command: full stack. Order: infra → warehouse → transpiler → Vulcan → MySQL proxy
	$(MAKE) network
	$(MAKE) certs
	$(MAKE) infra
	$(MAKE) warehouse
	$(MAKE) transpiler
	$(MAKE) vulcan-up
	$(MAKE) proxy-up
	@echo ""
	@echo "Ready: API http://localhost:18000/redoc  |  GraphQL http://localhost:13000"
	@echo "       Transpiler http://127.0.0.1:18100  |  MinIO http://localhost:9011"
	@echo "CLI:  make vulcan-cli CMD=\"plan\"   (uses $(VULCAN_IMAGE))"

down: all-down ## Alias: stop everything

certs: ## TLS for MySQL proxy + vulcan-mysql (docker/ssl/)
	@mkdir -p docker/ssl
	@if [ -f docker/ssl/server.crt ] && [ -f docker/ssl/server.key ]; then \
		echo "docker/ssl/server.crt present — skip"; \
	else \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
			-keyout docker/ssl/server.key -out docker/ssl/server.crt \
			-subj "/CN=vulcan-mysql" 2>/dev/null; \
		echo "Created docker/ssl/server.crt"; \
	fi

network: ## Docker network vulcan
	@docker network create vulcan 2>/dev/null || true

infra: network ## PostgreSQL statestore + MinIO
	$(DOCKER_COMPOSE) -p vulcan-statestore -f docker/docker-compose.infra.yml up -d --quiet-pull

warehouse: network ## PostgreSQL warehouse :5434
	$(DOCKER_COMPOSE) -p vulcan-warehouse -f docker/docker-compose.warehouse.yml up -d --quiet-pull
	@echo "Warehouse: localhost:15434 (user=vulcan, db=warehouse)"

warehouse-down: ## Stop warehouse
	$(DOCKER_COMPOSE) -p vulcan-warehouse -f docker/docker-compose.warehouse.yml down

transpiler: network ## Transpiler API :18100 (host), semantic :4000
	VERSION=$${VERSION:-0.0.0-exp.02} $(DOCKER_COMPOSE) -p vulcan-transpiler -f docker/docker-compose.transpiler.yml up -d --quiet-pull
	@echo "Transpiler: http://127.0.0.1:18100"

transpiler-down: ## Stop transpiler
	$(DOCKER_COMPOSE) -p vulcan-transpiler -f docker/docker-compose.transpiler.yml down

setup: network infra warehouse transpiler ## Statestore + MinIO + warehouse + transpiler (then: make vulcan-up or vulcan-api-docker)
	@echo "Optional: make vulcan-up && make proxy-up  (proxy needs vulcan-mysql running)"

vulcan-up: ## Vulcan API + GraphQL + MySQL containers (needs make certs)
	@test -f docker/ssl/server.crt || ($(MAKE) certs)
	VERSION=$${VERSION:-0.228.1.14} GRAPHQL_VERSION=$${GRAPHQL_VERSION:-0.228.1.14} \
		VULCAN_TENANT_ID=$${VULCAN_TENANT_ID:-ct-sandbox} \
		$(DOCKER_COMPOSE) -f docker/docker-compose.vulcan.yml up -d
	@echo "vulcan-api: http://localhost:18000/redoc"

vulcan-down: ## Stop Vulcan API stack
	VERSION=$${VERSION:-0.228.1.14} $(DOCKER_COMPOSE) -f docker/docker-compose.vulcan.yml down

proxy-up: network certs ## MySQL proxy :3306 (after vulcan-mysql is up, for BI tools)
	MYSQL_VERSION=$${MYSQL_VERSION:-0.0.0-exp.04} $(DOCKER_COMPOSE) -p vulcan-proxy -f docker/docker-compose.proxy.yml up -d --quiet-pull

proxy-down: ## Stop MySQL proxy
	$(DOCKER_COMPOSE) -p vulcan-proxy -f docker/docker-compose.proxy.yml down

infra-down: ## Stop statestore + minio
	$(DOCKER_COMPOSE) -p vulcan-statestore -f docker/docker-compose.infra.yml down

all-down: proxy-down vulcan-down transpiler-down warehouse-down infra-down ## Stop all compose stacks
	@echo "Stopped."

all-clean: all-down ## Remove volumes (destructive)
	@$(DOCKER_COMPOSE) -p vulcan-proxy -f docker/docker-compose.proxy.yml down -v 2>/dev/null || true
	@$(DOCKER_COMPOSE) -p vulcan-transpiler -f docker/docker-compose.transpiler.yml down -v 2>/dev/null || true
	@$(DOCKER_COMPOSE) -p vulcan-warehouse -f docker/docker-compose.warehouse.yml down -v 2>/dev/null || true
	@$(DOCKER_COMPOSE) -p vulcan-statestore -f docker/docker-compose.infra.yml down -v 2>/dev/null || true
	@$(DOCKER_COMPOSE) -f docker/docker-compose.vulcan.yml down -v 2>/dev/null || true
	@echo "Volumes removed where applicable."
