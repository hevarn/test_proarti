<?php
    
    namespace App\Controller;
    
    use App\Repository\ProjectRepository;
    use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
    use Symfony\Component\HttpFoundation\Response;
    use Symfony\Component\Routing\Annotation\Route;
    
    class ChoiceController extends AbstractController
    {
        #[Route( '/project', name: 'app_project' )]
        public function project(ProjectRepository $projectRepository): Response
        {
            return $this->render('generale/project.html.twig', [
                'projects' => $projectRepository->findAll(),
            ]);
        }
    }
