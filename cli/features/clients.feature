Feature: Clients

  Background:
    Given the following clients exist:
      | id  | name  |
      | 1   | One   |
      | 2   | Two   |
      | 3   | Three |

  Scenario: Index
    When I enter lauth "list clients"
    Then I should see
      """"
      1,One
      2,Two
      3,Three
      """

  Scenario Outline: Create
    When I enter lauth "create client name:<name>"
    Then I should see "<output>"

    Examples:
      | name  | output |
      | Four  | 4,Four |
      | One   | 4,One  |

  Scenario Outline: Read
    When I enter lauth "read client <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | error: 404 "Not Found" |
      | 1  | 1,One                  |

  Scenario Outline: Update
    When I enter lauth "update client <id> name:<name>"
    Then I should see "<output>"

    Examples:
      | id | name | output                 |
      | 4  | Four | error: 404 "Not Found" |
      | 1  | Uno  | 1,Uno                  |

  Scenario Outline: Delete
    When I enter lauth "delete client <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | error: 404 "Not Found" |
      | 1  | 1,One                  |
