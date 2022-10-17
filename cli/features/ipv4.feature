Feature: Internet Protocol Version 4 Utility

  Scenario: Internet Protocol (IP) Address
    When I enter lauth "ipv4 128.32.0.127"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/32'
        'address' : '128.32.0.127'
        'prefix' : 32
        'netmask' : '255.255.255.255'
      }
      """

  Scenario: IP Address with Netmask
    When I enter lauth "ipv4 128.32.0.127/255.255.255.0"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/24'
        'address' : '128.32.0.127'
        'prefix' : 24
        'netmask' : '255.255.255.0'
        'network' : '128.32.0.0'
        'first_host' : '128.32.0.1'
        'last_host' : '128.32.0.254'
        'broadcast' : '128.32.0.255'
        'host_count' : 254
      }
      """

  Scenario: IP Address with Prefix a.k.a. Classless Inter-Domain Routing (CIDR)
    When I enter lauth "ipv4 128.32.0.127/16"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/16'
        'address' : '128.32.0.127'
        'prefix' : 16
        'netmask' : '255.255.0.0'
        'network' : '128.32.0.0'
        'first_host' : '128.32.0.1'
        'last_host' : '128.32.255.254'
        'broadcast' : '128.32.255.255'
        'host_count' : 65534
      }
      """
