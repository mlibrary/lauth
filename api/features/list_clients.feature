Feature: List Clients

  Scenario: Empty List
    Given there are no clients
    When I visit "clients"
    Then I should see
      """
      [0]
      """

  Scenario: One client
    Given there is one client "one"
    When I visit "clients"
    Then I should see
      """
      [1]
      """

  Scenario: Two client
    Given there is two clients "one two"
    When I visit "clients"
    Then I should see
      """
      [2]
      """
