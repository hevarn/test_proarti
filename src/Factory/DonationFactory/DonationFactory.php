<?php
    
    namespace App\Factory\DonationFactory;
    
    use App\Entity\Donation;
    use App\Repository\DonationRepository;

    class DonationFactory
    {
        private DonationRepository $donationRepository;
    
        public function __construct(DonationRepository $donationRepository)
        {
            $this->donationRepository = $donationRepository;
        }
    
        /**
         * find if donation exist in DB or return new donation
         * @param string $amount
         * @return Donation
         */
        public function factory(string $amount): Donation
        {
            $donationDB = $this->donationRepository->findOneBy(["amount" => $amount ]);
            
            if($donationDB !== null){
                return $donationDB;
            }
            
            $donation = new Donation($amount);
            $donation->setAmount($amount);
            
            return $donation;
        }
    }