<?php

namespace App\Controller;

use App\Repository\PersonRepository;
use App\Repository\ProjectRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class GeneraleController extends AbstractController
{
    
    #[Route('/', name: 'app_home')]
    public function index( PersonRepository $personRepository): Response
    {
        return $this->render('generale/index.html.twig',[
            'persons' => $personRepository->findAll()
            ]);
    }
}
