<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\DonationRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: DonationRepository::class)]
#[ApiResource(
    denormalizationContext: ['groups' => ['donation:write']],
    normalizationContext: ['groups' => ['donation:read']],
)]
class Donation
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private $id;

    #[ORM\Column(type: 'integer')]
    #[Groups(["person:read","donation:read", "donation:write", "donation:write", "project:read"])]
    private ?int $amount;

    #[ORM\ManyToOne(targetEntity: Person::class, inversedBy: 'donations')]
    #[ORM\JoinColumn(nullable: true)]
    #[Groups(["donation:read", "donation:write"])]
    #[ApiProperty(readableLink: false, writableLink: false)]
    private ?Person $person;

    #[ORM\ManyToOne(targetEntity: Reward::class, inversedBy: 'donations')]
    #[ORM\JoinColumn(nullable: true)]
    #[Groups(["donation:read"])]
    private ?Reward $reward;
    
    
    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAmount(): ?int
    {
        return $this->amount;
    }

    public function setAmount(int $amount): self
    {
        $this->amount = $amount;

        return $this;
    }

    public function getPerson(): ?Person
    {
        return $this->person;
    }

    public function setPerson(?Person $person): self
    {
        $this->person = $person;

        return $this;
    }

    public function getReward(): ?Reward
    {
        return $this->reward;
    }

    public function setReward(?Reward $reward): self
    {
        $this->reward = $reward;

        return $this;
    }
}
