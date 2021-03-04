<?php

use Behat\MinkExtension\Context\RawMinkContext;

class ORMWriteContext extends RawMinkContext
{
    /**
     * @BeforeFeature @database
     * @BeforeScenario @database&&@clean
     */
    public static function createSchema(): void
    {
        \shell_exec('/srv/bin/console doctrine:database:drop --if-exists --force --env=test');
        \shell_exec('/srv/bin/console doctrine:database:create --if-not-exists --env=test');
        \shell_exec('/srv/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --quiet --env=test');
    }

    /**
     * @BeforeFeature @database&&@fixtures
     * @BeforeScenario @database&&@fixtures&&@clean
     */
    public static function loadFixtures(): void
    {
        \shell_exec('/srv/bin/console hautelook:fixtures:load --no-interaction --env=test');
    }
}
