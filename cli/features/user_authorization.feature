Feature: User Authorization

  Scenario: Unauthorized
    Given an unknown user "user" with password "password"
    When I enter lauth -n "user" -p "password" "list users"
    Then I should see
      """
      root
      """

  Scenario: Authorized
    Given a known user "user" with password "password"
    When I enter lauth -n "user" -p "password" "list users"
    Then I should see
      """
      root
      user
      """
