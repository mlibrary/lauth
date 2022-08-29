Feature: List Clients

  Scenario: Empty List
    Given there are no clients
    When I visit "clients"
    Then I should see
      """
      []
      """

  Scenario: One client
    Given there is one client "one"
    When I visit "clients"
    Then I should see
      """
      [{"type":"clients","id":"3","attributes":{"name":"one"}}]
      """

  Scenario: Two client
    Given there is two clients "one two"
    When I visit "clients"
    Then I should see
      """
      [{"type":"clients","id":"4","attributes":{"name":"one"}},{"type":"clients","id":"5","attributes":{"name":"two"}}]
      """
