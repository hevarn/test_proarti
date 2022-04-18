<?php
    namespace App\Factory\ProjectFactory;


    use App\Entity\Project;
    use App\Repository\ProjectRepository;

    class ProjectFactory
    {
    
        private ProjectRepository $projectRepository;
    
        public function __construct(ProjectRepository $projectRepository)
        {
            $this->projectRepository = $projectRepository;
        }
    
        /**
         * find if project exist in DB or return new project
         * @param string $projectName
         * @return Project
         */
        public function factory (string $projectName): Project
        {
            $projectExist = $this->projectRepository->findOneBy(["project_name" => $projectName]);
        
            if($projectExist !== null ){
                return $projectExist;
            
            }
            
            $project = new Project($projectName);
            $project->setProjectName($projectName);
            
            return $project;
        }
    
    }