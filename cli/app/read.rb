module Lauth
  module CLI
    module APP
      desc "Read Resource"
      arg_name "Resource"
      command :read do |read|
        read.desc "Read Client"
        read.arg_name "id"
        read.command :client do |client|
          client.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            read_client = repo.read(id).one

            puts "#{read_client.id}#{$separator}#{read_client.name}" if read_client # standard:disable Style/GlobalVars
          end
        end

        read.desc "Read Institution"
        read.arg_name "id"
        read.command :institution do |institution|
          institution.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            read_institution = repo.read(id).one

            puts "#{read_institution.id}#{$separator}#{read_institution.name}" if read_institution # standard:disable Style/GlobalVars
          end
        end

        read.desc "Read Network"
        read.arg_name "id"
        read.command :network do |network|
          network.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            read_network = repo.read(id).one

            puts "#{read_network.id}#{$separator}#{read_network.cidr}#{$separator}#{read_network.access}" if read_network # standard:disable Style/GlobalVars
          end
        end

        read.desc "Read User"
        read.arg_name "id"
        read.command :user do |user|
          user.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            read_user = repo.read(id).one

            puts "#{read_user.id}#{$separator}#{read_user.name}" if read_user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
