Feature: List Clients

  Scenario: Empty list
    Given there are no clients
    When I enter lauth "list clients" on the command line
    Then I should see
      """
      """

  Scenario: One client
    Given there is one client "one"
    When I enter lauth "list clients" on the command line
    Then I should see
      """
      one
      """

  Scenario: Two clients
    Given there is two clients "one two"
    When I enter lauth "list clients" on the command line
    Then I should see
      """
      one
      two
      """
