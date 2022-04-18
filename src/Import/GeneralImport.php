<?php
    
    namespace App\Import;
    
    use App\Factory\DonationFactory\DonationFactory;
    use App\Factory\PersonFactory\GetPersonFactory;
    use App\Factory\ProjectFactory\GetProjectFactory;
    use App\Factory\RewardFactory\RewardFactory;
    use Doctrine\ORM\EntityManagerInterface;
    use JetBrains\PhpStorm\NoReturn;


   
    class GeneralImport
    {
        
        private EntityManagerInterface $entityManager;
        private DonationFactory $donationFactory;
        private RewardFactory $rewardFactory;
        private GetPersonFactory $getPersonFactory;
        private GetProjectFactory $getProjectFactory;
    
    
        public function __construct(
            EntityManagerInterface $entityManager,
            DonationFactory $donationFactory,
            RewardFactory $rewardFactory,
            GetPersonFactory $getPersonFactory,
            GetProjectFactory $getProjectFactory,
        
        ) {
            
            $this->entityManager = $entityManager;
            $this->donationFactory = $donationFactory;
            $this->rewardFactory = $rewardFactory;
            $this->getPersonFactory = $getPersonFactory;
            $this->getProjectFactory = $getProjectFactory;
        }
    
        /**
         * initialize import csv data
         * @param array $datas
         * @Return void
         */
        #[NoReturn] public function initializeImport(array $datas):void
        {
            
            $personArray = [];
            $projectArray = [];
    
            foreach ($datas as $data) {
        
                $donation = $this->donationFactory->factory($data['amount']);
                $this->entityManager->persist($donation);
        
                $reward = $this->rewardFactory->factory(strtolower($data['reward']), $data['reward_quantity']);
                $this->entityManager->persist($reward);
                $reward->addDonation($donation);
        
                $project = $this->getProjectFactory->getProjet($data['project_name'], $projectArray);
                $project->addReward($reward);
        
                $person = $this->getPersonFactory->getPerson($data['first_name'], $data['last_name'], $personArray);
                $person->addDonation($donation);
        
        
            }
    
            $this->entityManager->flush();
            
        }
        
    
        
    
        
        
        
        
    }
    
    