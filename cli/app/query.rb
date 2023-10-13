module Lauth
  module CLI
    module APP
      desc "Query Resource"
      arg_name "Resource"
      command :query do |query|
        query.desc "Query Network"
        query.arg_name "<ip>"
        query.command :networks do |networks|
          networks.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            ip = IPAddress.parse args[0]

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            networks = repo.query(ip)

            networks.each do |network|
              puts "#{network.id}#{$separator}#{network.cidr}" # standard:disable Style/GlobalVars
            end
          end
        end
      end
    end
  end
end
