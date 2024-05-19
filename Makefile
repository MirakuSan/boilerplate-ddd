-include .env .env.local
export

# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP) bin/console

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor sf cc test open ps db-create db-update db-reset
.PHONY		  : php-cs-fixer php-cs-fixer-apply

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-z0-9A-Z_-]+:.*?##.*$$)|(^##)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##
## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the FrankenPHP container
	@$(PHP_CONT) sh

bash: ## Connect to the FrankenPHP container via bash so up and down arrows go to previous commands
	@$(PHP_CONT) bash

ps:
	@$(DOCKER_COMP) ps

open: ## Open the project in the browser
	@echo "${GREEN}Opening https://$(SERVER_NAME)"
	@open https://$(SERVER_NAME)

test: ## Start tests with phpunit, pass the parameter "c=" to add options to phpunit, example: make test c="--group e2e --stop-on-failure"
	@$(eval c ?=)
	@$(DOCKER_COMP) exec -e APP_ENV=test php bin/phpunit $(c)

##
## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

##
## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

db-create: ## Create the database
	@$(SYMFONY) doctrine:database:drop --force --if-exists -nq
	@$(SYMFONY) doctrine:database:create -nq

db-update: ## Update the database schema
	@$(SYMFONY) doctrine:migrations:update --force -nq

db-reset: db-create db-update ## Reset the database

##
## —— ✨ Code Quality ——————————————————————————————————————————————————————————
php-cs-fixer: ## PhpCsFixer (https://cs.symfony.com/)
	@$(PHP_CONT) vendor/bin/php-cs-fixer fix --using-cache=no --verbose --diff --dry-run

php-cs-fixer-apply: ## Applies PhpCsFixer fixes
	@$(PHP_CONT) vendor/bin/php-cs-fixer fix --using-cache=no --verbose --diff

phpstan: ## Run phpstan static analysis
	@$(PHP_CONT) vendor/bin/phpstan analyse --memory-limit=-1

psalm: ## Run psalm static analysis
	@$(PHP_CONT) vendor/bin/psalm --show-info=true

deptrac: ## Run code depedencies static analysis
	@echo "\n${YELLOW}Checking Bounded contexts...${RESET}"
	@$(PHP_CONT) vendor/bin/deptrac analyze --fail-on-uncovered --report-uncovered --no-progress --cache-file .deptrac_bc.cache --config-file deptrac_bc.yaml

	@echo "\n${YELLOW}Checking Hexagonal layers...${RESET}"
	@$(PHP_CONT) vendor/bin/deptrac analyze --fail-on-uncovered --report-uncovered --no-progress --cache-file .deptrac_hexa.cache --config-file deptrac_hexa.yaml
