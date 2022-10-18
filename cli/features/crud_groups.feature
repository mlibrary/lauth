Feature: Create, Read, Update, and Delete Groups

  Background:
    Given the following groups exist:
      | id | name  | deleted |
      | 1  | one   | f       |
      | 2  | two   | t       |
      | 3  | three | f       |
      | 4  | four  | t       |
      | 5  | five  | f       |
      | 6  | six   | t       |
      | 7  | seven | f       |
      | 8  | eight | t       |

  Scenario: Index
    When I enter lauth "list groups"
    Then I should see
      """"
      0,root
      1,one
      3,three
      5,five
      7,seven
      """

  Scenario Outline: Create
    When I enter lauth "create group <id> name:<name>"
    Then I should see "<output>"

    Examples:
      | id | name | output                 |
      | 4  | ruof | 4,ruof                 |
      | 1  | eno  | error: 403 "Forbidden" |
      | 9  | enin | 9,enin                 |

  Scenario Outline: Read
    When I enter lauth "read group <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | error: 404 "Not Found" |
      | 1  | 1,one                  |
      | 9  | error: 404 "Not Found" |

  Scenario Outline: Update
    When I enter lauth "update group <id> name:<name>"
    Then I should see "<output>"

    Examples:
      | id | name | output                 |
      | 4  | ruof | error: 404 "Not Found" |
      | 1  | eno  | 1,eno                  |
      | 9  | enin | error: 404 "Not Found" |

  Scenario Outline: Delete
    When I enter lauth "delete group <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | error: 404 "Not Found" |
      | 1  | 1,one                  |
      | 9  | error: 404 "Not Found" |
