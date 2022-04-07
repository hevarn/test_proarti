@database @fixtures @ex2
Feature: I should be interact with a crud API of project
  @write
  Scenario: I should be able to create a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "POST" request to "/rewards" with body:
    """
    {
      "project": 1,
      "name": "Pencil"
    }
    """
    Then the response status code should be 201
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should not be null
    And the JSON node "name" should be equal to "Pencil"
    And the JSON node "project" should be equal to "/projects/1"

  @write
  Scenario: I should be able to update a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/rewards/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Book 1"
    And the JSON node "project" should be equal to "/projects/1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "PUT" request to "/rewards/1" with body:
    """
    {
      "name": "Computer"
    }
    """
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Computer"
    And the JSON node "project" should be equal to "/projects/1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/rewards/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Computer"
    And the JSON node "project" should be equal to "/projects/1"

  @write
  Scenario: I should be able to delete a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/rewards/1"
    Then the response status code should be 200

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "DELETE" request to "/rewards/1"
    Then the response status code should be 204

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/rewards/1"
    Then the response status code should be 404
