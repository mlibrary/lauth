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
        'network' : '128.32.0.127'
        'first_host' : '128.32.0.127'
        'last_host' : '128.32.0.127'
        'broadcast' : '128.32.0.127'
        'host_count' : 1
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

  Scenario: Prefix -1
    When I enter lauth "ipv4 128.32.0.127/-1"
    Then I should see "error: Invalid netmask -1"

  Scenario: Prefix 0
    When I enter lauth "ipv4 128.32.0.127/0"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/0'
        'address' : '128.32.0.127'
        'prefix' : 0
        'netmask' : '0.0.0.0'
        'network' : '0.0.0.0'
        'first_host' : '0.0.0.1'
        'last_host' : '255.255.255.254'
        'broadcast' : '255.255.255.255'
        'host_count' : 4294967294
      }
      """

  Scenario: Prefix 1
    When I enter lauth "ipv4 128.32.0.127/1"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/1'
        'address' : '128.32.0.127'
        'prefix' : 1
        'netmask' : '128.0.0.0'
        'network' : '128.0.0.0'
        'first_host' : '128.0.0.1'
        'last_host' : '255.255.255.254'
        'broadcast' : '255.255.255.255'
        'host_count' : 2147483646
      }
      """

  Scenario: Prefix 30
    When I enter lauth "ipv4 128.32.0.127/30"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/30'
        'address' : '128.32.0.127'
        'prefix' : 30
        'netmask' : '255.255.255.252'
        'network' : '128.32.0.124'
        'first_host' : '128.32.0.125'
        'last_host' : '128.32.0.126'
        'broadcast' : '128.32.0.127'
        'host_count' : 2
      }
      """

  Scenario: Prefix 31
    When I enter lauth "ipv4 128.32.0.127/31"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/31'
        'address' : '128.32.0.127'
        'prefix' : 31
        'netmask' : '255.255.255.254'
        'network' : '128.32.0.126'
        'first_host' : '128.32.0.126'
        'last_host' : '128.32.0.127'
        'broadcast' : '128.32.0.127'
        'host_count' : 2
      }
      """

  Scenario: Prefix 32
    When I enter lauth "ipv4 128.32.0.127/32"
    Then I should see
      """
      {
        'cidr' : '128.32.0.127/32'
        'address' : '128.32.0.127'
        'prefix' : 32
        'netmask' : '255.255.255.255'
        'network' : '128.32.0.127'
        'first_host' : '128.32.0.127'
        'last_host' : '128.32.0.127'
        'broadcast' : '128.32.0.127'
        'host_count' : 1
      }
      """

  Scenario: Prefix 33
    When I enter lauth "ipv4 128.32.0.127/33"
    Then I should see "error: Prefix must be in range 0..32, got: 33"
