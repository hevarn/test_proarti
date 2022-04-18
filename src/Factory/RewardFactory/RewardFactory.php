<?php
    
    namespace App\Factory\RewardFactory;
    
    use App\Entity\Donation;
    use App\Entity\Project;
    use App\Entity\Reward;
    use App\Repository\RewardRepository;

    class RewardFactory
    {
    
        private RewardRepository $rewardRepository;
    
        public function __construct(RewardRepository $rewardRepository)
        {
            $this->rewardRepository = $rewardRepository;
        }
    
        /**
         * find in DB if exist or return new reward
         * @param string $rewardName
         * @param int $rewardQuantity
         * @return Reward
         */
        public function factory(string $rewardName, int $rewardQuantity): Reward
        {
            $rewardDB = $this->rewardRepository->findOneBy(["reward" => $rewardName ]);
        
            if($rewardDB !== null){
                return $rewardDB;
            }
            
            $reward = new Reward($rewardName, $rewardQuantity);
            $reward->setReward($rewardName);
            $reward->setRewardQuantity($rewardQuantity);
            
            return $reward;
        }
    }