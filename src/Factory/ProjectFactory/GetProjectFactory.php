<?php
    
    namespace App\Factory\ProjectFactory;
    
    use App\Entity\Project;
    use Doctrine\ORM\EntityManagerInterface;

    class GetProjectFactory
    {
        private ProjectFactory $projectFactory;
        private EntityManagerInterface $entityManager;
    
    
        public function __construct(ProjectFactory $projectFactory, EntityManagerInterface $entityManager)
        {
    
            $this->projectFactory = $projectFactory;
            $this->entityManager = $entityManager;
        }
    
        /**
         * dump the project in the array and check if it's not already there
         * @param string $dataProjectName
         * @param array $projectArray
         * @return Project
         */
        public function getProjet(string $dataProjectName, array &$projectArray): Project
        {
            $projectName = $this->cleanWord($dataProjectName);
            if (array_key_exists($projectName, $projectArray)) {
                return $projectArray[$projectName ];
            
            }
            $project = $this->projectFactory->factory(strtolower($projectName));
            $this->entityManager->persist($project);
            $projectArray[ $projectName] = $project;
        
            return $project;
        }
    
        /**
         * replace character with accent and return string clear
         * @param string $str
         * @return array|string|null
         */
        private function cleanWord(string $str): array|string|null
        {
            $str = htmlentities($str, ENT_NOQUOTES, 'utf-8');
            $str = preg_replace('#&([A-za-z])(?:uml|circ|tilde|acute|grave|cedil|ring);#', '\1', $str);
            $str = preg_replace('#&([A-za-z]{2})(?:lig);#', '\1', $str);
            $str = preg_replace('#&[^;]+;#', '', $str);
        
            return $str;
        }
    
    }