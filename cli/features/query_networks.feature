Feature: Query Networks

  Background:
    Given the following networks exist:
      | id  | cidr         | deleted |
      | 1   | 1.2.3.3/8    | f       |
      | 2   | 2.2.3.3/8    | t       |
      | 3   | 128.0.3.3/16 | t       |
      | 4   | 128.1.3.3/16 | f       |
      | 5   | 192.0.0.3/24 | f       |
      | 6   | 192.0.1.3/24 | t       |

  Scenario Outline: Networks include? IP Address
    When I enter lauth "query networks <ip>"
    Then I should see "<output>"

    Examples:
      | ip        | output         |
      | 1.2.3.3   | 1,1.0.0.0/8    |
      | 2.3.3.3   |                |
      | 128.0.3.3 |                |
      | 128.1.3.3 | 4,128.1.0.0/16 |
      | 192.0.0.3 | 5,192.0.0.0/24 |
      | 192.0.1.3 |                |
