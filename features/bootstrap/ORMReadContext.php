<?php

use Behat\MinkExtension\Context\RawMinkContext;

class ORMReadContext extends RawMinkContext
{
    /**
     * @BeforeSuite
     */
    public static function clearDatabase(): void
    {
        \shell_exec('/srv/bin/console doctrine:database:drop --if-exists --force --env=test');
        \shell_exec('/srv/bin/console doctrine:database:create --if-not-exists --env=test');
        \shell_exec('/srv/bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --quiet --env=test');
        \shell_exec('/srv/bin/console hautelook:fixtures:load --no-interaction --quiet --env=test');
    }
}
