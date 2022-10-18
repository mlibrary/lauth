Feature: Groups

  Background:
    Given user "Name" with credentials "user:password"
    Given the following groups exist:
      | id  | name        | deleted |
      | 1   | Group One   | f       |
      | 2   | Group Two   | f       |
      | 3   | Group Three | f       |
      | 4   | Group Four  | t       |
      | 5   | Group Five  | f       |
      | 6   | Group Six   | t       |
      | 7   | Group Seven | f       |
      | 8   | Group Eight | t       |

  Scenario: Groups
    When I visit "groups"
    Then I should see
      """
      {"data":[
        {"type":"groups","id":0,"attributes":{"name":"root"}},
        {"type":"groups","id":1,"attributes":{"name":"Group One"}},
        {"type":"groups","id":2,"attributes":{"name":"Group Two"}},
        {"type":"groups","id":3,"attributes":{"name":"Group Three"}},
        {"type":"groups","id":5,"attributes":{"name":"Group Five"}},
        {"type":"groups","id":7,"attributes":{"name":"Group Seven"}}
      ]}
      """

  Scenario: Create Group - Not Found (Unknown)
    When I post '{"data":{"type":"groups","id":9,"attributes":{"name":"Nine"}}}' to "groups"
    Then I should see
      """
      {"data":{"type":"groups","id":9,"attributes":{"name":"Nine"}}}
      """

  Scenario: Create Group - Not Found (Deleted)
    When I post '{"data":{"type":"groups","id":8,"attributes":{"name":"Eight"}}}' to "groups"
    Then I should see
      """
      {"data":{"type":"groups","id":8,"attributes":{"name":"Eight"}}}
      """

  Scenario: Create Group - Found
    When I post '{"data":{"type":"groups","id":3,"attributes":{"name":"Three"}}}' to "groups"
    Then I should see
      """
      {"errors":[{"error":{"code":403, "msg":"Forbidden"}}]}
      """

  Scenario: Read Group - Not Found (Unknown)
    When I visit "groups/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Group - Not Found (Deleted)
    When I visit "groups/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Group - Found
    When I visit "groups/3"
    Then I should see
      """
     {"data":{"type":"groups","id":3,"attributes":{"name":"Group Three"}}}
      """

  Scenario: Update Group - Not Found (Unknown)
    When I put '{"data":{"type":"groups","id":9,"attributes":{"name":"Nine"}}}' to "groups/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Group - Not Found (Deleted)
    When I put '{"data":{"type":"groups","id":8,"attributes":{"name":"Eight"}}}' to "groups/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Group - Found
    When I put '{"data":{"type":"groups","id":3,"attributes":{"name":"Three"}}}' to "groups/3"
    Then I should see
      """
     {"data":{"type":"groups","id":3,"attributes":{"name":"Three"}}}
      """

  Scenario: Delete Group - Not Found (Unknown)
    When I delete "groups/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Group  - Not Found (Deleted)
    When I delete "groups/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Group - Found
    When I delete "groups/3"
    Then I should see
      """
     {"data":{"type":"groups","id":3,"attributes":{"name":"Group Three"}}}
      """
