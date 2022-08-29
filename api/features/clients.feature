Feature: Clients

  Scenario: Two client
    Given there is two clients "one two"
    When I visit "clients"
    Then I should see
      """
      [{"type":"clients","id":"1","attributes":{"name":"one"}},{"type":"clients","id":"2","attributes":{"name":"two"}}]
      """
