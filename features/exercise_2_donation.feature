@database @fixtures @ex2
Feature: I should be interact with a crud API of project
  @write
  Scenario: I should be able to create a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "POST" request to "/donations" with body:
    """
    {
      "amount": 84
      "reward": 1
      "person": 1
    }
    """
    Then the response status code should be 201
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "@id" should not be null
    And the JSON node "amount" should be equal to "84"
    And the JSON node "reward" should be equal to "/rewards/1"
    And the JSON node "person" should be equal to "/people/1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Donner des ailes 1"
    And the JSON node "totalAmount" should be equal to "126"

  @write
  Scenario: I should be able to update a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/donations/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Donner des ailes 1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I add "Content-Type" header equal to "application/ld+json"
    And I send a "PUT" request to "/donations/1" with body:
    """
    {
      "amount": 168
    }
    """
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "amount" should be equal to "168"
    And the JSON node "reward" should be equal to "/rewards/1"
    And the JSON node "person" should be equal to "/people/1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/donations/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "amount" should be equal to "168"
    And the JSON node "reward" should be equal to "/rewards/1"
    And the JSON node "person" should be equal to "/people/1"

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Donner des ailes 1"
    And the JSON node "totalAmount" should be equal to "168"

  @write
  Scenario: I should be able to delete a project
    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/donations/1"
    Then the response status code should be 200

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "DELETE" request to "/donations/1"
    Then the response status code should be 204

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/donations/1"
    Then the response status code should be 404

    When I add 'Accept' header equal to 'application/ld+json'
    And I send a "GET" request to "/projects/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/ld+json; charset=utf-8"
    And the JSON node "name" should be equal to "Donner des ailes 1"
    And the JSON node "totalAmount" should be equal to "0"
