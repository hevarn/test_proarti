<?php
    
    namespace App\Factory\PersonFactory;
    
    use App\Entity\Person;
    use Doctrine\ORM\EntityManagerInterface;


    class GetPersonFactory
    {
        private PersonFactory $personFactory;
        private EntityManagerInterface $entityManager;
    
    
        public function __construct(PersonFactory $personFactory, EntityManagerInterface $entityManager)
        {
    
            $this->personFactory = $personFactory;
    
            $this->entityManager = $entityManager;
        }
    
        /**
         * dump the person in the array and check if it's not already there
         * @param string $dataFirstName
         * @param string $dataLastName
         * @param $personArray
         * @return Person
         */
        public function getPerson(string $dataFirstName, string $dataLastName, &$personArray): Person
        {
            $firstName = trim(strtolower($dataFirstName));
            $lastName = trim(strtolower($dataLastName));
            
            if (array_key_exists($firstName.' '.$lastName, $personArray)) {
                return $personArray[ $firstName.' '.$lastName ];
                
            }
            $person = $this->personFactory->factory($firstName, $lastName);
            $this->entityManager->persist($person);
            $personArray[ $firstName.' '.$lastName ] = $person;
            
            return $person;
        }
    }