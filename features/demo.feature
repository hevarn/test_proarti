@database @fixtures
Feature: My demo

  @read
  Scenario: I should be able to go to homepage
    When I go to "/"
    Then the response status code should be 404
