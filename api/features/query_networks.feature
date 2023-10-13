Feature: Query Networks

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

  Scenario: IP not contain by any network
    When I visit "networks?ip=128.0.3.3"
    Then I should see
      """
      {"data":[]}
      """

  Scenario: IP contain by one network
    When I visit "networks?ip=128.1.3.3"
    Then I should see
      """
      {"data":[{"attributes":{"access":"allow","cidr":"128.1.0.0/16"},"id":4,"type":"networks"}]}
      """
