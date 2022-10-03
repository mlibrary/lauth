Feature: Create, Read, Update, and Delete Networks

  Background:
    Given the following networks exist:
      | id  | cidr          | deleted |
      | 1   | 44.0.0.0/24   | f       |
      | 2   | 45.0.0.0/24   | t       |
      | 3   | 128.33.0.0/16 | t       |
      | 4   | 128.32.0.0/16 | f       |
      | 5   | 192.12.33.0/8 | f       |
      | 6   | 192.12.34.0/8 | t       |

  Scenario: Index
    When I enter lauth "list networks"
    Then I should see
      """"
      1,44.0.0.0/24,allow
      4,128.32.0.0/16,allow
      5,192.12.33.0/8,allow
      """

  Scenario Outline: Create
    When I enter lauth "create network <id> cidr:\"<cidr>\""
    Then I should see "<output>"

    Examples:
      | id | cidr          | output                 |
      | 4  | 128.33.0.0/16 | error: 403 "Forbidden" |
      | 4  | 128.32.0.0/16 | error: 403 "Forbidden" |
      | 2  | 128.33.0.0/16 | 2,128.33.0.0/16,allow  |
      | 2  | 128.32.0.0/16 | 2,128.32.0.0/16,allow  |
      | 7  | 128.33.0.0/16 | 7,128.33.0.0/16,allow  |
      | 7  | 128.32.0.0/16 | 7,128.32.0.0/16,allow  |


  Scenario Outline: Read
    When I enter lauth "read network <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | 4,128.32.0.0/16,allow  |
      | 2  | error: 404 "Not Found" |
      | 7  | error: 404 "Not Found" |

  Scenario Outline: Update
    When I enter lauth "update network <id> cidr:\"<cidr>\""
    Then I should see "<output>"

    Examples:
      | id | cidr          | output                 |
      | 4  | 192.12.34.0/8 | 4,192.12.34.0/8,allow  |
      | 4  | 192.12.33.0/8 | 4,192.12.33.0/8,allow  |
      | 2  | 192.12.34.0/8 | error: 404 "Not Found" |
      | 2  | 192.12.33.0/8 | error: 404 "Not Found" |
      | 7  | 192.12.34.0/8 | error: 404 "Not Found" |
      | 7  | 192.12.33.0/8 | error: 404 "Not Found" |

  Scenario Outline: Delete
    When I enter lauth "delete network <id>"
    Then I should see "<output>"

    Examples:
      | id | output                 |
      | 4  | 4,128.32.0.0/16,allow  |
      | 2  | error: 404 "Not Found" |
      | 7  | error: 404 "Not Found" |
