@database @fixtures @ex2
Feature: I should be interact with a crud API of project
  @write
  Scenario: I should be able to create a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "POST" request to "/projects" with body:
    """
    {
      "name": "My test project"
    }
    """
    Then the response status code should be 201
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should not be null
    And the JSON node "name" should be equal to "My test project"
    And the JSON node "totalAmount" should be equal to "42"

  @write
  Scenario: I should be able to update a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Donner des ailes 1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "PUT" request to "/projects/1" with body:
    """
    {
      "name": "My test project updated"
    }
    """
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "My test project updated"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "My test project updated"

  @write
  Scenario: I should be able to delete a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "DELETE" request to "/projects/1"
    Then the response status code should be 204

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 404
