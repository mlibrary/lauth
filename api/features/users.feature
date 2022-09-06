Feature: Users

  Scenario: Root user
    Given there is a root user
    When I visit "users/root"
    Then I should see
      """
     {"type":"users","id":"root","attributes":{"name":"User"}}
      """

  Scenario: Users
    Given there are users
    When I visit "users"
    Then I should see
      """
      [{"type":"users","id":"root","attributes":{"name":"User"}},{"type":"users","id":"user1","attributes":{"name":"surname1"}}]
      """
