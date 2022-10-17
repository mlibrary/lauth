Feature: Create, Read, Update, and Delete Institutions

  Background:
    Given the following institutions exist:
      | id  | name                           | deleted |
      | 1   | University of Michigan         | f       |
      | 2   | Michigan State University      | t       |
      | 3   | Eastern Michigan University    | f       |
      | 4   | Western Michigan University    | t       |
      | 5   | Wayne State University         | f       |
      | 6   | Central Michigan University    | t       |
      | 7   | Michigan Technology University | f       |
      | 8   | Oakland University             | t       |

  Scenario: Index
    When I enter lauth "list institutions"
    Then I should see
      """"
      1,University of Michigan
      3,Eastern Michigan University
      5,Wayne State University
      7,Michigan Technology University
      """

  Scenario Outline: Create
    When I enter lauth "create institution <id> name:\"<name>\""
    Then I should see "<output>"

    Examples:
      | id | name             | output                 |
      | 4  | Western Michigan | 4,Western Michigan     |
      | 1  | Michigan         | error: 403 "Forbidden" |
      | 9  | University       | 9,University           |

  Scenario Outline: Read
    When I enter lauth "read institution <id>"
    Then I should see "<output>"

    Examples:
      | id | output                   |
      | 4  | error: 404 "Not Found"   |
      | 1  | 1,University of Michigan |
      | 9  | error: 404 "Not Found"   |

  Scenario Outline: Update
    When I enter lauth "update institution <id> name:\"<name>\""
    Then I should see "<output>"

    Examples:
      | id | name             | output                 |
      | 4  | Western Michigan | error: 404 "Not Found" |
      | 1  | Michigan         | 1,Michigan             |
      | 9  | University       | error: 404 "Not Found" |

  Scenario Outline: Delete
    When I enter lauth "delete institution <id>"
    Then I should see "<output>"

    Examples:
      | id | output                   |
      | 4  | error: 404 "Not Found"   |
      | 1  | 1,University of Michigan |
      | 9  | error: 404 "Not Found"   |
