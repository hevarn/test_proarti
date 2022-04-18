<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20220418081433 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE donation (id INT AUTO_INCREMENT NOT NULL, person_id INT DEFAULT NULL, reward_id INT DEFAULT NULL, amount INT NOT NULL, INDEX IDX_31E581A0217BBB47 (person_id), INDEX IDX_31E581A0E466ACA1 (reward_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('CREATE TABLE person (id INT AUTO_INCREMENT NOT NULL, first_name VARCHAR(255) NOT NULL, last_name VARCHAR(255) NOT NULL, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, UNIQUE INDEX UNIQ_34DCD176C808BA5A (last_name), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('CREATE TABLE project (id INT AUTO_INCREMENT NOT NULL, project_name VARCHAR(255) NOT NULL, UNIQUE INDEX UNIQ_2FB3D0EE67B2B61E (project_name), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('CREATE TABLE reward (id INT AUTO_INCREMENT NOT NULL, project_id INT DEFAULT NULL, reward VARCHAR(255) NOT NULL, reward_quantity INT NOT NULL, INDEX IDX_4ED17253166D1F9C (project_id), PRIMARY KEY(id)) DEFAULT CHARACTER SET utf8mb4 COLLATE `utf8mb4_unicode_ci` ENGINE = InnoDB');
        $this->addSql('ALTER TABLE donation ADD CONSTRAINT FK_31E581A0217BBB47 FOREIGN KEY (person_id) REFERENCES person (id)');
        $this->addSql('ALTER TABLE donation ADD CONSTRAINT FK_31E581A0E466ACA1 FOREIGN KEY (reward_id) REFERENCES reward (id)');
        $this->addSql('ALTER TABLE reward ADD CONSTRAINT FK_4ED17253166D1F9C FOREIGN KEY (project_id) REFERENCES project (id)');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE donation DROP FOREIGN KEY FK_31E581A0217BBB47');
        $this->addSql('ALTER TABLE reward DROP FOREIGN KEY FK_4ED17253166D1F9C');
        $this->addSql('ALTER TABLE donation DROP FOREIGN KEY FK_31E581A0E466ACA1');
        $this->addSql('DROP TABLE donation');
        $this->addSql('DROP TABLE person');
        $this->addSql('DROP TABLE project');
        $this->addSql('DROP TABLE reward');
    }
}
