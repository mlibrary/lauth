Feature: Authorized

  Background:
    Given user "Name" with id "id" and password "password"

  Scenario: Unknown User
    When I enter lauth -u "di" -p "password" "read user id"
    Then I should see
      """
      error: 401 "Unauthorized"
      """

  Scenario: Wrong Password
    When I enter lauth -u "id" -p "drowssap" "read user id"
    Then I should see
      """
      error: 401 "Unauthorized"
      """

  Scenario: Correct Password
    When I enter lauth -u "id" -p "password" "read user id"
    Then I should see
      """
      id,Name
      """
