Feature: User Authorization

  Background:
    Given an authorized user "user" with password "password"

  Scenario: Unknown User
    When I enter lauth -u "resu" -p "password" "list users"
    Then I should see
      """
      """

  Scenario: Wrong Password
    When I enter lauth -u "user" -p "drowssap" "list users"
    Then I should see
      """
      """

  Scenario: Correct Password
    When I enter lauth -u "user" -p "password" "list users"
    Then I should see
      """
      root
      user
      """
