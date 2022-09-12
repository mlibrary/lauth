Feature: Authenticate

  Scenario: User Anonymous
    Given no user credentials
    When I visit "users/root"
    Then I should see
      """
      Unauthorized
      """

  Scenario: User Unknown
    Given user credentials "user:password"
    When I visit "users/root"
    Then I should see
      """
      Unauthorized
      """

  Scenario: User Wrong Password
    Given user credentials "root:password"
    When I visit "users/root"
    Then I should see
      """
      Unauthorized
      """

  Scenario: User Correct Password
    Given user credentials "root:!none"
    When I visit "users/root"
    Then I should see
      """
      {"type":"users","id":"root","attributes":{"name":"User"}}
      """
