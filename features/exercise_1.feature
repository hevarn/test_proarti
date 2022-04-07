@database @fixtures @ex1
Feature: I should be able to load csv file and display the result

  @write
  Scenario: I should be able to load csv file by command line
    When I execute "bin/console app:csv-load data_exam.csv" from project root
    Then command should succeed
    And output should contain "Pièce de théatre sur le théme du Chocapic"

    When I go to "/"
    Then I should see "Upload csv file"
    And I should not see "File uploaded with success"
    And I should see "Pièce de théatre sur le théme du Chocapic"

  @write @clean
  Scenario: I should be able to load csv file by web page
    When I go to "/"
    Then I should see "Upload csv file"

    When I attach the file "../data_exam.csv" to "Upload csv file"
    And I press "submit"
    Then I should see "File uploaded with success"
    And I should see "Pièce de théatre sur le théme du Chocapic"
