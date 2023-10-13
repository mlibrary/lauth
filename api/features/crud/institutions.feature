Feature: CRUD Institutions

  Background:
    Given user "Name" with credentials "user:password"
    Given the following institutions exist:
      | id  | name                           | deleted |
      | 1   | University of Michigan         | f       |
      | 2   | Michigan State University      | f       |
      | 3   | Eastern Michigan University    | f       |
      | 4   | Western Michigan University    | t       |
      | 5   | Wayne State University         | f       |
      | 6   | Central Michigan University    | t       |
      | 7   | Michigan Technology University | f       |
      | 8   | Oakland University             | t       |

  Scenario: Institutions
    When I visit "institutions"
    Then I should see
      """
      {"data":[
        {"type":"institutions","id":1,"attributes":{"name":"University of Michigan"}},
        {"type":"institutions","id":2,"attributes":{"name":"Michigan State University"}},
        {"type":"institutions","id":3,"attributes":{"name":"Eastern Michigan University"}},
        {"type":"institutions","id":5,"attributes":{"name":"Wayne State University"}},
        {"type":"institutions","id":7,"attributes":{"name":"Michigan Technology University"}}
      ]}
      """
    
  Scenario: Create Institution - Not Found (Unknown)
    When I post '{"data":{"type":"institutions","id":9,"attributes":{"name":"9emaN"}}}' to "institutions"
    Then I should see
      """
      {"data":{"type":"institutions","id":9,"attributes":{"name":"9emaN"}}}
      """

  Scenario: Create Institution - Not Found (Deleted)
    When I post '{"data":{"type":"institutions","id":8,"attributes":{"name":"8emaN"}}}' to "institutions"
    Then I should see
      """
      {"data":{"type":"institutions","id":8,"attributes":{"name":"8emaN"}}}
      """

  Scenario: Create Institution - Found
    When I post '{"data":{"type":"institutions","id":3,"attributes":{"name":"3emaN"}}}' to "institutions"
    Then I should see
      """
      {"errors":[{"error":{"code":403, "msg":"Forbidden"}}]}
      """

  Scenario: Read Institution - Not Found (Unknown)
    When I visit "institutions/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Institution - Not Found (Deleted)
    When I visit "institutions/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Institution - Found
    When I visit "institutions/3"
    Then I should see
      """
     {"data":{"type":"institutions","id":3,"attributes":{"name":"Eastern Michigan University"}}}
      """

  Scenario: Update Institution - Not Found (Unknown)
    When I put '{"data":{"type":"institutions","id":9,"attributes":{"name":"9emaN"}}}' to "institutions/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Institution - Not Found (Deleted)
    When I put '{"data":{"type":"institutions","id":8,"attributes":{"name":"8emaN"}}}' to "institutions/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Institution - Found
    When I put '{"data":{"type":"institutions","id":3,"attributes":{"name":"3emaN"}}}' to "institutions/3"
    Then I should see
      """
     {"data":{"type":"institutions","id":3,"attributes":{"name":"3emaN"}}}
      """

  Scenario: Delete Institution - Not Found (Unknown)
    When I delete "institutions/9"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Institution  - Not Found (Deleted)
    When I delete "institutions/8"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Institution - Found
    When I delete "institutions/3"
    Then I should see
      """
     {"data":{"type":"institutions","id":3,"attributes":{"name":"Eastern Michigan University"}}}
      """
