Feature: Authenticate

  Scenario: User Anonymous
    Given no user credentials
    When I visit "users/root"
    Then I should see
      """
      {"errors":[{"error":{"code":401,"msg":"Unauthorized"}}]}
      """

  Scenario: User Unknown
    Given user credentials "user:password"
    When I visit "users/root"
    Then I should see
      """
      {"errors":[{"error":{"code":401,"msg":"Unauthorized"}}]}
      """

  Scenario: User Wrong Password
    Given user credentials "root:password"
    When I visit "users/root"
    Then I should see
      """
      {"errors":[{"error":{"code":401,"msg":"Unauthorized"}}]}
      """

  Scenario: User Correct Password
    Given user credentials "root:!none"
    When I visit "users/root"
    Then I should see
      """
      {"data":{"type":"users","id":"root","attributes":{"name":"User"}}}
      """
