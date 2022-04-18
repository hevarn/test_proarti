<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\RewardRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use JetBrains\PhpStorm\Pure;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: RewardRepository::class)]
#[ApiResource(
    denormalizationContext: ['groups' => ['reward:write']],
    normalizationContext: ['groups' => ['reward:read']],
)]
class Reward
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private $id;

    #[ORM\Column(type: 'string', length: 255)]
    #[Groups(["reward:read", "reward:write", "person:read", "donation:read", "project:read"])]
    private ?string $reward;

    #[ORM\Column(type: 'integer')]
    #[Groups(["reward:read", "reward:write", "person:read", "donation:read", "project:read"])]
    private ?int $reward_quantity;

    #[ORM\OneToMany(mappedBy: 'reward', targetEntity: Donation::class, orphanRemoval: true)]
    #[Groups(["reward:read", "reward:write", "project:read"])]
    private ?Collection $donations;

    #[ORM\ManyToOne(targetEntity: Project::class, inversedBy: 'rewards')]
    #[Groups(["reward:read", "reward:write"])]
    private ?Project $project;

    
    public function getId(): ?int
    {
        return $this->id;
    }

    public function getReward(): ?string
    {
        return $this->reward;
    }

    public function setReward(string $reward): self
    {
        $this->reward = $reward;

        return $this;
    }
    
    public function setRewardQuantity(int $reward_quantity): self
    {
        $this->reward_quantity = $reward_quantity;

        return $this;
    }
    
    public function getRewardQuantity(): ?int
    {
        return $this->reward_quantity;
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
        $donations = new ArrayCollection();
        if (!$donations->contains($donation)) {
            $donations[] = $donation;
            $donation->setReward($this);
        }

        return $this;
    }

    public function removeDonation(?Donation $donation): self
    {
        if ($this->donations->removeElement($donation)) {
            // set the owning side to null (unless already changed)
            if ($donation->getReward() === $this) {
                $donation->setReward(null);
            }
        }

        return $this;
    }

    public function getProject(): ?Project
    {
        return $this->project;
    }

    public function setProject(?Project $project): self
    {
        $this->project = $project;

        return $this;
    }
}
