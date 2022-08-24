Feature: Users

  Scenario: Root user
    Given there is a root user
    When I visit "users/root"
    Then I should see
      """
      [0]
      """
