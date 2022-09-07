Feature: Clients

  Background:
    Given an authorized user with credentials "user:password"

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
      [{"type":"clients","id":"1","attributes":{"name":"one"}}]
      """

  Scenario: Two client
    Given there is two clients "one two"
    When I visit "clients"
    Then I should see
      """
      [{"type":"clients","id":"2","attributes":{"name":"one"}},{"type":"clients","id":"3","attributes":{"name":"two"}}]
      """
