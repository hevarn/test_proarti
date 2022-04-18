<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\ProjectRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use JetBrains\PhpStorm\Pure;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: ProjectRepository::class)]
#[ApiResource(
    denormalizationContext: ['groups' => ['project:write']],
    normalizationContext: ['groups' => ['project:read']],
)]
class Project
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private $id;

    #[ORM\Column(type: 'string', length: 255, unique: true)]
    #[Groups(["project:read", "project:read", "reward:write"])]
    private ?string $project_name;

    #[ORM\OneToMany(mappedBy: 'project', targetEntity: Reward::class)]
    #[Groups(["project:read"])]
    private Collection $rewards;
    
    #[Pure] public function __construct($project_name)
    {
        $this->rewards = new ArrayCollection();
        $this->project_name = $project_name;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getProjectName(): ?string
    {
        return $this->project_name;
    }

    public function setProjectName(string $project_name): self
    {
        $this->project_name = $project_name;

        return $this;
    }

    /**
     * @return Collection<int, Reward>
     */
    public function getRewards(): Collection
    {
        return $this->rewards;
    }

    public function addReward(Reward $reward): self
    {
        if (!$this->rewards->contains($reward)) {
            $this->rewards[] = $reward;
            $reward->setProject($this);
        }

        return $this;
    }
    
    public function removeReward(Reward $reward): self
    {
        if ($this->rewards->removeElement($reward)) {
            // set the owning side to null (unless already changed)
            if ($reward->getProject() === $this) {
                $reward->setProject(null);
            }
        }

        return $this;
    }
}
