Feature: Create, Read, Update, and Delete Collections

  Background:
    Given the following collections exist:
      | id           | name             | deleted |
      | Identifier_1 | Collection One   | f       |
      | Identifier_2 | Collection Two   | t       |
      | Identifier_3 | Collection Three | f       |
      | Identifier_4 | Collection Four  | t       |
      | Identifier_5 | Collection Five  | f       |
      | Identifier_6 | Collection Six   | t       |
      | Identifier_7 | Collection Seven | f       |
      | Identifier_8 | Collection Eight | t       |

  Scenario: Index
    When I enter lauth "list collections"
    Then I should see
      """"
      Identifier_1,Collection One
      Identifier_3,Collection Three
      Identifier_5,Collection Five
      Identifier_7,Collection Seven
      """

  Scenario Outline: Create
    When I enter lauth "create collection <id> name:\"<name>\""
    Then I should see "<output>"

    Examples:
      | id           | name            | output                       |
      | Identifier_4 | Four Collection | Identifier_4,Four Collection |
      | Identifier_1 | One Collection  | error: 403 "Forbidden"       |
      | Identifier_9 | Nine Collection | Identifier_9,Nine Collection |

  Scenario Outline: Read
    When I enter lauth "read collection <id>"
    Then I should see "<output>"

    Examples:
      | id           | output                      |
      | Identifier_4 | error: 404 "Not Found"      |
      | Identifier_1 | Identifier_1,Collection One |
      | Identifier_9 | error: 404 "Not Found"      |

  Scenario Outline: Update
    When I enter lauth "update collection <id> name:\"<name>\""
    Then I should see "<output>"

    Examples:
      | id           | name | output                 |
      | Identifier_4 | Four | error: 404 "Not Found" |
      | Identifier_1 | One  | Identifier_1,One       |
      | Identifier_9 | Nine | error: 404 "Not Found" |

  Scenario Outline: Delete
    When I enter lauth "delete collection <id>"
    Then I should see "<output>"

    Examples:
      | id           | output                      |
      | Identifier_4 | error: 404 "Not Found"      |
      | Identifier_1 | Identifier_1,Collection One |
      | Identifier_9 | error: 404 "Not Found"      |
