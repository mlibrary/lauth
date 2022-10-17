module Lauth
  module CLI
    module APP
      desc "Internet Protocol Version 4 Utility"
      long_desc %(
          lauth ipv4 128.32.0.127

          lauth ipv4 128.32.0.127/16

          lauth ipv4 128.32.0.127/255.255.255.0
      )
      arg_name "<ipv4_address>[/(<prefix>|<netmask>)]"
      command :ipv4 do |ipv4|
        ipv4.desc "hello"
        ipv4.action do |global_options, options, args|
          # If you have any errors, just raise them
          raise "that command made no sense" unless args[0]
          ip = IPAddress.parse(args[0])
          host_count = ip.broadcast.to_u32 - ip.network.to_u32 - 1
          puts "{"
          puts "  'cidr' : '#{ip.to_string}'"
          puts "  'address' : '#{ip.address}'"
          puts "  'prefix' : #{ip.prefix}"
          puts "  'netmask' : '#{ip.netmask}'"
          if host_count > 0
            puts "  'network' : '#{ip.network}'"
            puts "  'first_host' : '#{ip.first}'"
            puts "  'last_host' : '#{ip.last}'"
            puts "  'broadcast' : '#{ip.broadcast}'"
            puts "  'host_count' : #{host_count}"
          end
          puts "}"
        end
      end
    end
  end
end
