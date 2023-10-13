Feature: CRUD Networks

  Background:
    Given user "Name" with credentials "user:password"
    Given the following networks exist:
      | id  | cidr         | deleted |
      | 1   | 1.2.3.3/8    | f       |
      | 2   | 2.2.3.3/8    | t       |
      | 3   | 128.0.3.3/16 | t       |
      | 4   | 128.1.3.3/16 | f       |
      | 5   | 192.0.0.3/24 | f       |
      | 6   | 192.0.1.3/24 | t       |

  Scenario: Networks
    When I visit "networks"
    Then I should see
      """
      {"data":[
        {"type":"networks","id":1,"attributes":{"cidr":"1.0.0.0/8","access":"allow"}},
        {"type":"networks","id":4,"attributes":{"cidr":"128.1.0.0/16","access":"allow"}},
        {"type":"networks","id":5,"attributes":{"cidr":"192.0.0.0/24","access":"allow"}}
      ]}
      """

  Scenario: Create Network - Not Found (Unknown)
    When I post '{"data":{"type":"networks","id":7,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks"
    Then I should see
      """
      {"data":{"type":"networks","id":7,"attributes":{"cidr":"45.45.43.0/24","access":"allow"}}}
      """

  Scenario: Create Network - Not Found (Deleted)
    When I post '{"data":{"type":"networks","id":6,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks"
    Then I should see
      """
      {"data":{"type":"networks","id":6,"attributes":{"cidr":"45.45.43.0/24","access":"allow"}}}
      """

  Scenario: Create Network - Found
    When I post '{"data":{"type":"networks","id":4,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks"
    Then I should see
      """
      {"errors":[{"error":{"code":403, "msg":"Forbidden"}}]}
      """

  Scenario: Read Network - Not Found (Unknown)
    When I visit "networks/7"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Network - Not Found (Deleted)
    When I visit "networks/6"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Network - Found
    When I visit "networks/4"
    Then I should see
      """
     {"data":{"type":"networks","id":4,"attributes":{"cidr":"128.1.0.0/16","access":"allow"}}}
      """

  Scenario: Update Network - Not Found (Unknown)
    When I put '{"data":{"type":"networks","id":7,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks/7"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Network - Not Found (Deleted)
    When I put '{"data":{"type":"networks","id":6,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks/6"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Network - Found
    When I put '{"data":{"type":"networks","id":4,"attributes":{"cidr":"45.45.43.45/24"}}}' to "networks/4"
    Then I should see
      """
     {"data":{"type":"networks","id":4,"attributes":{"cidr":"45.45.43.0/24","access":"allow"}}}
      """

  Scenario: Delete Network - Not Found (Unknown)
    When I delete "networks/7"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Network  - Not Found (Deleted)
    When I delete "networks/6"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Network - Found
    When I delete "networks/4"
    Then I should see
      """
     {"data":{"type":"networks","id":4,"attributes":{"cidr":"128.1.0.0/16","access":"allow"}}}
      """
