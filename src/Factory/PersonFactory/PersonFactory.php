<?php
    namespace App\Factory\PersonFactory;
    
    use App\Entity\Person;
    use App\Repository\PersonRepository;


    class PersonFactory
    {
        private PersonRepository $personRepository;
    
        public function __construct(PersonRepository $personRepository){
        
            $this->personRepository = $personRepository;
        }
    
        
        /**
         * find if person exist in DB or return new person
         * @param string $firstName
         * @param string $lastName
         * @return Person
         */
        public function factory(string $firstName, string $lastName): Person
        {
        
            $personDB = $this->personRepository->findOneBy(["last_name" => $lastName, "first_name"=> $firstName]);
        
            if($personDB !== null){
                
                return $personDB;
            
            }
            
            $person =new Person($firstName, $lastName);
            
            $person->setFirstName($firstName);
            $person->setLastName($lastName);
            
            return $person;
        
        }
    }