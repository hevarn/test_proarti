@database @fixtures @ex2
Feature: I should be interact with a crud API of project
  @write
  Scenario: I should be able to create a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "POST" request to "/people" with body:
    """
    {
      "firstName": "R2",
      "lastName": "D2"
    }
    """
    Then the response status code should be 201
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should not be null
    And the JSON node "firstName" should be equal to "R2"
    And the JSON node "lastName" should be equal to "D2"

  @write
  Scenario: I should be able to update a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/people/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "firstName" should be equal to "Jean 1"
    And the JSON node "lastName" should be equal to "Dupont 1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "PUT" request to "/people/1" with body:
    """
    {
      "firstName": "C3",
      "lastName": "PO"
    }
    """
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "firstName" should be equal to "C3"
    And the JSON node "lastName" should be equal to "PO"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/people/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "firstName" should be equal to "C3"
    And the JSON node "lastName" should be equal to "PO"

  @write
  Scenario: I should be able to delete a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/people/1"
    Then the response status code should be 200

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "DELETE" request to "/people/1"
    Then the response status code should be 204

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/people/1"
    Then the response status code should be 404
