Feature: CRUD Clients

  Background:
    Given user "Name" with credentials "client:password"
    Given the following clients exist:
      | id | name  |
      | 1  | Name1 |
      | 2  | Name2 |
      | 3  | Name3 |

  Scenario: Clients
    When I visit "clients"
    Then I should see
      """
      {"data":[
        {"type":"clients","id":1,"attributes":{"name":"Name1"}},
        {"type":"clients","id":2,"attributes":{"name":"Name2"}},
        {"type":"clients","id":3,"attributes":{"name":"Name3"}}
      ]}
      """
  
  Scenario: Create Client - Not Found
    When I post '{"data":{"type":"clients","id":4,"attributes":{"name":"4emaN"}}}' to "clients"
    Then I should see
      """
      {"data":{"type":"clients","id":4,"attributes":{"name":"4emaN"}}}
      """
    
  Scenario: Create Client - Found
    When I post '{"data":{"type":"clients","id":3,"attributes":{"name":"3emaN"}}}' to "clients"
    Then I should see
      """
      {"errors":[{"error":{"code":403, "msg":"Forbidden"}}]}
      """

  Scenario: Read Client - Not Found
    When I visit "clients/4"
    Then I should see
      """
     {"errors":[{"error":{"code":404,"msg":"Not Found"}}]}
      """

  Scenario: Read Client - Found
    When I visit "clients/3"
    Then I should see
      """
     {"data":{"type":"clients","id":3,"attributes":{"name":"Name3"}}}
      """

  Scenario: Update Client - Not Found
    When I put '{"data":{"type":"clients","id":4,"attributes":{"name":"4emaN"}}}' to "clients/4"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Update Client - Found
    When I put '{"data":{"type":"clients","id":3,"attributes":{"name":"3emaN"}}}' to "clients/3"
    Then I should see
      """
     {"data":{"type":"clients","id":3,"attributes":{"name":"3emaN"}}}
      """

  Scenario: Delete Client - Not Found
    When I delete "clients/4"
    Then I should see
      """
     {"errors":[{"error":{"code":404, "msg":"Not Found"}}]}
      """

  Scenario: Delete Client - Found
    When I delete "clients/3"
    Then I should see
      """
     {"data":{"type":"clients","id":3,"attributes":{"name":"Name3"}}}
      """
