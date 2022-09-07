Feature: Users

  Background:
    Given an authorized user with credentials "user:password"

  Scenario: User
    When I visit "users/user"
    Then I should see
      """
     {"type":"users","id":"user","attributes":{"name":"user"}}
      """

  Scenario: Users
    When I visit "users"
    Then I should see
      """
      [{"type":"users","id":"root","attributes":{"name":"User"}},{"type":"users","id":"user","attributes":{"name":"user"}}]
      """
