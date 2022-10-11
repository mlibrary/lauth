Feature: Users

  Background:
    Given user "Name" with credentials "user:password"
    Given the following users exist:
      | id    | name  | deleted |
      | user1 | Name1 | f       |
      | user2 | Name2 | f       |
      | user3 | Name3 | f       |
      | user4 | Name4 | t       |
      | user5 | Name5 | f       |
      | user6 | Name6 | t       |
      | user7 | Name7 | f       |
      | user8 | Name8 | t       |

  Scenario: Index Users
    When I visit "users"
    Then I should see
      """
      {"data":[
        {"type":"users","id":"root","attributes":{"name":"User"}},
        {"type":"users","id":"user","attributes":{"name":"Name"}},
        {"type":"users","id":"user1","attributes":{"name":"Name1"}},
        {"type":"users","id":"user2","attributes":{"name":"Name2"}},
        {"type":"users","id":"user3","attributes":{"name":"Name3"}},
        {"type":"users","id":"user5","attributes":{"name":"Name5"}},
        {"type":"users","id":"user7","attributes":{"name":"Name7"}}
      ]}
      """

  Scenario: Create User - Not Found (Unknown)
    When I post '{"data":{"type":"users","id":"user9","attributes":{"name":"9emaN"}}}' to "users"
    Then I should see
      """
      {"data":{"type":"users","id":"user9","attributes":{"name":"9emaN"}}}
      """

  Scenario: Create User - Not Found (Deleted)
    When I post '{"data":{"type":"users","id":"user8","attributes":{"name":"8emaN"}}}' to "users"
    Then I should see
      """
      {"data":{"type":"users","id":"user8","attributes":{"name":"8emaN"}}}
      """

  Scenario: Create User - Found
    When I post '{"data":{"type":"users","id":"user3","attributes":{"name":"3emaN"}}}' to "users"
    Then I should see
      """
      {"errors":[{"error":{"code":403, "msg":"Forbidden"}}]}
      """

  Scenario: Read User - Not Found (Unknown)
    When I visit "users/user9"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read User - Not Found (Deleted)
    When I visit "users/user8"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read User - Found
    When I visit "users/user3"
    Then I should see
      """
     {"data":{"type":"users","id":"user3","attributes":{"name":"Name3"}}}
      """

  Scenario: Update User - Not Found (Unknown)
    When I put '{"data":{"type":"users","id":"user9","attributes":{"name":"9emaN"}}}' to "users/user9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update User - Not Found (Deleted)
    When I put '{"data":{"type":"users","id":"user8","attributes":{"name":"8emaN"}}}' to "users/user8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update User - Found
    When I put '{"data":{"type":"users","id":"user3","attributes":{"name":"3emaN"}}}' to "users/user3"
    Then I should see
      """
     {"data":{"type":"users","id":"user3","attributes":{"name":"3emaN"}}}
      """

  Scenario: Delete User - Not Found (Unknown)
    When I delete "users/user9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete User  - Not Found (Deleted)
    When I delete "users/user8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete User - Found
    When I delete "users/user3"
    Then I should see
      """
     {"data":{"type":"users","id":"user3","attributes":{"name":"Name3"}}}
      """
