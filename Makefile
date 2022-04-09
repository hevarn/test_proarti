DOCKER_COMPOSE = docker-compose
DOCKER_EXEC     = $(DOCKER_COMPOSE) exec
DOCKER_RUN     = $(DOCKER_COMPOSE) run --rm

EXEC_APP = $(DOCKER_EXEC) app /entrypoint
EXEC_PHP = $(DOCKER_EXEC) app /entrypoint php -d memory_limit=-1

SYMFONY = $(EXEC_PHP) bin/console
COMPOSER = $(EXEC_PHP) /usr/local/bin/composer

QA = docker run --rm -v $(PWD):/project cacahouete/phpaudit:8.1.3
DOCKERIZE = $(DOCKER_RUN) dockerize
APP_SRC = src

##
## Project
## -------
##

build: docker-compose.override.yml
	$(DOCKER_COMPOSE) pull --ignore-pull-failures
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 $(DOCKER_COMPOSE) build --pull

kill: docker-compose.override.yml
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --volumes --remove-orphans

install: ## Install and start the project
install: build
	mkdir -p var/log
	$(MAKE) start
	$(MAKE) db

reset: ## Stop and start a fresh install of the project
reset: kill
	$(MAKE) install

start: ## Start the project
start: docker-compose.override.yml
	$(DOCKER_COMPOSE) up -d --remove-orphans --no-recreate

ss: ## Start Simple : start the project and install db
ss: start docker-compose.override.yml
	$(MAKE) db

stop: ## Stop the project
stop: docker-compose.override.yml
	$(DOCKER_COMPOSE) stop

clean: ## Stop the project and remove generated files
clean: kill
	rm -rf vendor var/cache

thanks:
	$(COMPOSER) thanks

docker-compose.override.yml: docker-compose.override.yml.dist
ifeq ($(shell test -f docker-compose.override.yml && echo -n yes),yes)
	@echo "Your docker-compose.override.yml is outdated."
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "# Do you want to refresh your docker-compose.override.yml ? [y/N] : " CONTINUE; \
	done ; \
	if [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ]; then \
		cp docker-compose.override.yml.dist docker-compose.override.yml ; \
		echo "=> Refresh done" ; \
	fi
else
	cp -n docker-compose.override.yml.dist docker-compose.override.yml
endif

.PHONY: build kill install reset start stop clean thanks

##
## Utils
## -----
##

cc: ## Do a cache clear
cc: vendor
	$(SYMFONY) cache:clear

db: ## Reset the database
db: vendor db-wait
	-$(SYMFONY) doctrine:database:drop --if-exists --force
	-$(SYMFONY) doctrine:database:create --if-not-exists
	$(SYMFONY) doctrine:migrations:migrate --no-interaction --allow-no-migration --quiet

db-test: ## Reset the database for test
db-test: vendor db-wait
	-$(SYMFONY) doctrine:database:drop --if-exists --force --env=test
	-$(SYMFONY) doctrine:database:create --if-not-exists --env=test
	$(SYMFONY) doctrine:migrations:migrate --no-interaction --allow-no-migration --quiet --env=test

db-wait: ## Wait for db up
	@$(DOCKERIZE) -wait tcp://postgres:5432 -timeout 20s

db-validate: ## Validate doctrine schema
db-validate: vendor db-wait
	$(SYMFONY) doctrine:schema:validate

db-dump: ## Dump sql diff
db-dump: vendor db-wait
	$(SYMFONY) doctrine:schema:update --dump-sql

db-diff: ## Generate a new doctrine migration
db-diff: vendor db-wait
	$(SYMFONY) doctrine:migrations:diff

db-migr: ## Run a doctrine migration
db-migr: vendor db-wait
	$(SYMFONY) doctrine:migrations:migrate --no-interaction --allow-no-migration

.PHONY: db db-test db-validate db-diff

##
## Tests
## -----
##

test: ## Run unit and functional tests
test: tu tf

tu: ## Run unit tests
tu: vendor
	$(EXEC_PHP) -d extension=pcov.so bin/phpunit

tf: ## Run functional tests
tf: vendor db-test
	$(EXEC_PHP) vendor/bin/behat --colors

tf1: ## Run functional tests exercice 1
tf1: vendor db-test
	$(EXEC_PHP) vendor/bin/behat --colors --tags ex1

tf2: ## Run functional tests exercice 2
tf2: vendor db-test
	$(EXEC_PHP) vendor/bin/behat --colors --tags ex2

# rules based on files
update: composer.json
	$(COMPOSER) update --no-interaction

composer.lock: composer.json
	$(COMPOSER) update --lock --no-scripts --no-interaction

vendor: composer.lock
	$(COMPOSER) install

.PHONY: tests tu tf tf1 tf2 update

##
## Quality assurance
## -----------------
##

lint: ## Lints twig and yaml files
lint: lt ly

lt: vendor
	$(SYMFONY) cache:clear
	$(SYMFONY) lint:twig src
	$(SYMFONY) lint:twig templates

ly: vendor
	$(SYMFONY) lint:yaml src --parse-tags
	$(SYMFONY) lint:yaml config --parse-tags

security: ## Check security of your dependencies (https://security.sensiolabs.org/)
	docker run --rm -v $(PWD):/app cacahouete/local-php-security-checker-docker

md: ## PHP Mess Detector (https://phpmd.org)
	$(QA) phpmd $(APP_SRC) text .phpmd.xml

phpcpd: ## PHP Copy/Paste Detector (https://github.com/sebastianbergmann/phpcpd)
	$(QA) phpcpd $(APP_SRC)

stan: ## twig code style
	$(QA) php -d memory_limit=50000M /usr/local/src/vendor/bin/phpstan.phar analyse

twigcs: ## twig code style
	$(QA) twigcs lint src

cs: ## php-cs-fixer (http://cs.sensiolabs.org)
	$(QA) php-cs-fixer fix --dry-run --using-cache=no --verbose --diff

cs-fix: ## apply php-cs-fixer fixes
	$(QA) php-cs-fixer fix

.PHONY: lint lt ly phpmd phpcpd phpdcd cs cs-fix

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
