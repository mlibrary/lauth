Feature: Collections

  Background:
    Given user "Name" with credentials "user:password"
    Given the following collections exist:
      | id          | name             | deleted |
      | Identifier1 | Collection One   | f       |
      | Identifier2 | Collection Two   | f       |
      | Identifier3 | Collection Three | f       |
      | Identifier4 | Collection Four  | t       |
      | Identifier5 | Collection Five  | f       |
      | Identifier6 | Collection Six   | t       |
      | Identifier7 | Collection Seven | f       |
      | Identifier8 | Collection Eight | t       |

  Scenario: Collections
    When I visit "collections"
    Then I should see
      """
      {"data":[
        {"type":"collections","id":"Identifier1","attributes":{"name":"Collection One"}},
        {"type":"collections","id":"Identifier2","attributes":{"name":"Collection Two"}},
        {"type":"collections","id":"Identifier3","attributes":{"name":"Collection Three"}},
        {"type":"collections","id":"Identifier5","attributes":{"name":"Collection Five"}},
        {"type":"collections","id":"Identifier7","attributes":{"name":"Collection Seven"}}
      ]}
      """

  Scenario: Create Collection - Not Found (Unknown)
    When I post '{"data":{"type":"collections","id":"Identifier9","attributes":{"name":"Nine Collection"}}}' to "collections"
    Then I should see
      """
      {"data":{"type":"collections","id":"Identifier9","attributes":{"name":"Nine Collection"}}}
      """

  Scenario: Create Collection - Not Found (Deleted)
    When I post '{"data":{"type":"collections","id":"Identifier8","attributes":{"name":"Eight Collection"}}}' to "collections"
    Then I should see
      """
      {"data":{"type":"collections","id":"Identifier8","attributes":{"name":"Eight Collection"}}}
      """

  Scenario: Create Collection - Found
    When I post '{"data":{"type":"collections","id":"Identifier3","attributes":{"name":"Three Collection"}}}' to "collections"
    Then I should see
      """
      {"errors":[{"error":{"code":403,"msg":"Forbidden"}}]}
      """

  Scenario: Read Collection - Not Found (Unknown)
    When I visit "collections/Identifier9"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Collection - Not Found (Deleted)
    When I visit "collections/Identifier8"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Collection - Found
    When I visit "collections/Identifier3"
    Then I should see
      """
     {"data":{"type":"collections","id":"Identifier3","attributes":{"name":"Collection Three"}}}
      """

  Scenario: Update Collection - Not Found (Unknown)
    When I put '{"data":{"type":"collections","id":"Identifier9","attributes":{"name":"Nine Collection"}}}' to "collections/Identifier9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Collection - Not Found (Deleted)
    When I put '{"data":{"type":"collections","id":"Identifier8","attributes":{"name":"Eight Collection"}}}' to "collections/Identifier8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Collection - Found
    When I put '{"data":{"type":"collections","id":"Identifier3","attributes":{"name":"Three Collection"}}}' to "collections/Identifier3"
    Then I should see
      """
     {"data":{"type":"collections","id":"Identifier3","attributes":{"name":"Three Collection"}}}
      """

  Scenario: Delete Collection - Not Found (Unknown)
    When I delete "collections/Identifier9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Collection  - Not Found (Deleted)
    When I delete "collections/Identifier8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Collection - Found
    When I delete "collections/Identifier3"
    Then I should see
      """
     {"data":{"type":"collections","id":"Identifier3","attributes":{"name":"Collection Three"}}}
      """
