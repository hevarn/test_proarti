<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\PersonRepository;
use DateTime;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use JetBrains\PhpStorm\Pure;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: PersonRepository::class)]
#[ApiResource(
    denormalizationContext: ['groups' => ['person:write', "person:read"]],
    normalizationContext: ['groups' => ['person:read']],
)]
class Person
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    #[Groups(["person:read", "donation:read"])]
    private $id;

    #[ORM\Column(type: 'string', length: 255)]
    #[Groups(["person:read", 'person:write', "donation:read", "donation:write"])]
    private ?string $first_name;

    #[ORM\Column(type: 'string', length: 255, unique: true)]
    #[Groups(["person:read", 'person:write', "donation:read", "donation:write"])]
    private ?string $last_name;

    #[ORM\OneToMany(mappedBy: 'person', targetEntity: Donation::class, cascade:["persist"])]
    #[Groups(["person:read", 'person:write'])]
    private Collection $donations;

    #[ORM\Column(type: 'datetime')]
    #[Groups("person:read")]
    private ?\DateTime $created_at;

    #[ORM\Column(type: 'datetime')]
    #[Groups("person:read")]
    private ?\DateTime $updated_at;
    
    #[Pure] public function __construct()
    {
        $this->donations = new ArrayCollection();
        $this->created_at = new DateTime();
        $this->updated_at = new DateTime();
    }

    
    public function getId(): ?int
    {
        return $this->id;
    }
    
    public function getFirstName(): ?string
    {
        return $this->first_name;
    }
    
    public function setFirstName(string $first_name): self
    {
        $this->first_name = $first_name;

        return $this;
    }
    
    #[Groups(['read_person:collection'])]
    public function getLastName(): ?string
    {
        return $this->last_name;
    }

    public function setLastName(string $last_name): self
    {
        $this->last_name = $last_name;

        return $this;
    }

    /**
     * @return Collection<int, Donation>
     */
    
    public function getDonations(): Collection
    {
        return $this->donations;
    }

    public function addDonation(?Donation $donation): self
    {
        if (!$this->donations->contains($donation)) {
            $this->donations[] = $donation;
            $donation->setPerson($this);
        }

        return $this;
    }

    public function removeDonation(?Donation $donation): self
    {
        if ($this->donations->removeElement($donation)) {
            // set the owning side to null (unless already changed)
            if ($donation->getPerson() === $this) {
                $donation->setPerson(null);
            }
        }

        return $this;
    }

    public function getCreatedAt(): DateTime
    {
        return $this->created_at;
    }

    public function setCreatedAt(\DateTime $created_at): self
    {
        $this->created_at = $created_at;

        return $this;
    }

    public function getUpdatedAt(): DateTime
    {
        return $this->updated_at;
    }

    public function setUpdatedAt(\DateTime $updated_at): self
    {
        $this->updated_at = $updated_at;

        return $this;
    }
}
