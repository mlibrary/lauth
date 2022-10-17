Feature: Create, Read, Update, and Delete Users

  Background:
    Given the following users exist:
      | id      | name  | password  | deleted |
      | user1   | User1 | password1 | f       |
      | user2   | User2 | password2 | t       |
      | user3   | User3 | password3 | f       |
      | user4   | User4 | password4 | t       |
      | user5   | User5 | password5 | f       |
      | user6   | User6 | password6 | t       |
      | user7   | User7 | password7 | f       |
      | user8   | User8 | password8 | t       |

  Scenario: Index
    When I enter lauth "list users"
    Then I should see
      """"
      root,User
      user1,User1
      user3,User3
      user5,User5
      user7,User7
      """

  Scenario Outline: Create
    When I enter lauth "create user <id> name:<name>"
    Then I should see "<output>"

    Examples:
      | id     | name  | output                 |
      | user4  | 4resU | user4,4resU            |
      | user1  | 1resU | error: 403 "Forbidden" |
      | user9  | 9resU | user9,9resU            |

  Scenario Outline: Read
    When I enter lauth "read user <id>"
    Then I should see "<output>"

    Examples:
      | id     | output                 |
      | user4  | error: 404 "Not Found" |
      | user1  | user1,User1            |
      | user9  | error: 404 "Not Found" |

  Scenario Outline: Update
    When I enter lauth "update user <id> name:<name>"
    Then I should see "<output>"

    Examples:
      | id     | name  | output                 |
      | user4  | 4resU | error: 404 "Not Found" |
      | user1  | 1resU | user1,1resU            |
      | user9  | 9resU | error: 404 "Not Found" |
    
  Scenario Outline: Delete
    When I enter lauth "delete user <id>"
    Then I should see "<output>"

    Examples:
      | id     | output                 |
      | user4  | error: 404 "Not Found" |
      | user1  | user1,User1            |
      | user9  | error: 404 "Not Found" |
