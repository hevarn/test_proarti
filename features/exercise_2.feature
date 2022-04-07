@database @fixtures @ex2
Feature: I should be interact with a crud API

  @read
  Scenario Outline: I should be able to get collection of each entity
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "<endpoint>"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should be equal to "<endpoint>"
    And the JSON node "hydra:totalItems" should be equal to 0
    Examples:
      | endpoint   |
      | /persons   |
      | /donations |
      | /rewards   |
      | /projects  |

  @read
  Scenario Outline: I should be able to get item of each entity
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "<endpoint>"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should be equal to "<endpoint>"
    Examples:
      | endpoint   |
      | /persons/1   |
      | /donations/1 |
      | /rewards/1   |
      | /projects/1  |
