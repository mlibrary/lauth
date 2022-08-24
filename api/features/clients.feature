Feature: Clients

  Scenario: Two client
    Given there is two clients "one two"
    When I visit "clients"
    Then I should see
      """
      [2]
      """
