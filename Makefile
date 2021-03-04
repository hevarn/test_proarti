DOCKER_COMPOSE = docker-compose
DOCKER_EXEC     = $(DOCKER_COMPOSE) exec
DOCKER_RUN     = $(DOCKER_COMPOSE) run --rm

EXEC_APP = $(DOCKER_EXEC) app /entrypoint
EXEC_PHP = $(DOCKER_EXEC) app /entrypoint php -d memory_limit=-1
EXEC_PG = $(DOCKER_EXEC) postgres /docker-entrypoint.sh
EXEC_RUBY = $(DOCKER_EXEC) ruby /entrypoint

SYMFONY = $(EXEC_PHP) bin/console
COMPOSER = $(EXEC_PHP) /usr/local/bin/composer

QA = docker run --rm -v $(PWD):/project cacahouete/phpaudit:8.0
DOCKERIZE = $(DOCKER_RUN) dockerize

##
## Project
## -------
##

build:
	$(DOCKER_COMPOSE) pull --ignore-pull-failures
	COMPOSE_DOCKER_CLI_BUILD=1 $(DOCKER_COMPOSE) build --pull

kill:
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
	$(DOCKER_COMPOSE) up -d --remove-orphans --no-recreate

ss: ## Start Simple : start the project and install db
ss: start
	$(MAKE) db

start-deploy: ## Start only deploy dependencies
	$(DOCKER_COMPOSE) up -d --remove-orphans --no-recreate ruby

stop: ## Stop the project
	$(DOCKER_COMPOSE) stop

clean: ## Stop the project and remove generated files
clean: kill
	rm -rf vendor var/cache

thanks:
	$(COMPOSER) thanks

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

bin/phpunit/.phpunit/phpunit-9.5-0: vendor
	$(EXEC_PHP) bin/phpunit install

test: ## Run unit and functional tests
test: tu tf

tu: ## Run unit tests
tu: vendor bin/phpunit/.phpunit/phpunit-9.5-0
	$(EXEC_PHP) -d extension=pcov.so bin/phpunit --exclude-group functional

tf: ## Run functional tests
tf: vendor bin/phpunit/.phpunit/phpunit-9.5-0 db-test
	$(EXEC_PHP) bin/phpunit --group functional
	$(EXEC_PHP) vendor/bin/behat --colors

# rules based on files
update: composer.json
	$(COMPOSER) update --no-interaction

composer.lock: composer.json
	$(COMPOSER) update --lock --no-scripts --no-interaction

vendor: composer.lock
	$(COMPOSER) install

.PHONY: tests tu tf update

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

local-php-security-checker:
	$(EXEC_APP) curl -sSL https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64 -o local-php-security-checker
	$(EXEC_APP) chmod +x local-php-security-checker

security: ## Check security of your dependencies (https://security.sensiolabs.org/)
security: local-php-security-checker
	$(EXEC_APP) ./local-php-security-checker

phploc: ## PHPLoc (https://github.com/sebastianbergmann/phploc)
	$(QA) phploc $(APP_SRC)/

pdepend: ## PHP_Depend (https://pdepend.org)
pdepend: artefacts
	$(QA) pdepend \
		--summary-xml=$(ARTEFACTS)/pdepend_summary.xml \
		--jdepend-chart=$(ARTEFACTS)/pdepend_jdepend.svg \
		--overview-pyramid=$(ARTEFACTS)/pdepend_pyramid.svg \
		src/

md: ## PHP Mess Detector (https://phpmd.org)
	$(QA) phpmd $(APP_SRC) text .phpmd.xml

phpcodesnifer: ## PHP_CodeSnifer (https://github.com/squizlabs/PHP_CodeSniffer)
#	$(QA) phpcs --standard=./vendor/escapestudios/symfony2-coding-standard/Symfony/ --report-full $(APP_SRC)
	$(QA) phpcs --standard=.phpcs.xml --report-full $(APP_SRC)

phpcpd: ## PHP Copy/Paste Detector (https://github.com/sebastianbergmann/phpcpd)
	$(QA) phpcpd $(APP_SRC)

phpdcd: ## PHP Dead Code Detector (https://github.com/sebastianbergmann/phpdcd)
	$(QA) phpdcd $(APP_SRC)

phpmetrics: ## PhpMetrics (http://www.phpmetrics.org)
phpmetrics: artefacts
	$(QA) phpmetrics --report-html=$(ARTEFACTS)/phpmetrics $(APP_SRC)

stan: ## twig code style
	$(QA) php -d memory_limit=50000M /usr/local/src/vendor/bin/phpstan.phar analyse

twigcs: ## twig code style
	$(QA) twigcs lint src

cs: ## php-cs-fixer (http://cs.sensiolabs.org)
	$(QA) php-cs-fixer fix --dry-run --using-cache=no --verbose --diff

cs-fix: ## apply php-cs-fixer fixes
	$(QA) php-cs-fixer fix

.PHONY: lint lt ly phploc pdepend phpmd phpcodesnifer phpcpd phpdcd phpmetrics cs cs-fix

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help
