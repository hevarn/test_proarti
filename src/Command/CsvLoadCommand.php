<?php

namespace App\Command;

use App\Import\GeneralImport;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\Serializer\Encoder\CsvEncoder;
use Symfony\Component\Serializer\Normalizer\ObjectNormalizer;
use Symfony\Component\Serializer\Serializer;

#[AsCommand(
    name: 'app:csv-load',
    description: 'Add a short description for your command',
)]
class CsvLoadCommand extends Command
{
    private string $fileDir;
    private generalImport $import;
    
    protected function configure(): void
    {
        $this
            ->setDescription('Upload document')
            ->setHelp('This command allows to upload file in different formats (csv|xml|yaml)')
            ->addArgument('fileName', InputArgument::OPTIONAL, 'Name file');;
    }
    
    public function __construct(string $fileDir, GeneralImport $import)
    {
        parent::__construct();
        $this->fileDir = $fileDir;
        $this->import = $import;
    }
    
    /**
     * get file name and call decodeCSV function
     * @param InputInterface $input
     * @param OutputInterface $output
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $serviceName = $input->getArgument('fileName');
        $io = new SymfonyStyle($input, $output);
        
        if (is_null($serviceName)) {
            $serviceName = $io->ask("what is your name file ??", "data_exam.csv");
        }
        
        $this->decodeCsv($serviceName);
        
        $io->success("File uploaded with success");
        
        return Command::SUCCESS;
        
        
    }
    
    
    /**
     * @param string $serviceName
     * @return void
     */
    protected function decodeCsv(string $serviceName): void
    {
        // configure argument
        $file = $this->fileDir.DIRECTORY_SEPARATOR.$serviceName;
        
        $encoders = [ new CsvEncoder() ];
        $normalizers = [ new ObjectNormalizer() ];
        $serializer = new Serializer($normalizers, $encoders);
        
        $datas = $serializer->decode(file_get_contents($file), 'csv', [ CsvEncoder::DELIMITER_KEY => ';' ]);
        
        $this->import->initializeImport($datas);
    }
}
