module Lauth
  module CLI
    module APP
      desc "Delete Resource"
      arg_name "Resource"
      command :delete do |delete|
        delete.desc "Delete Client"
        delete.arg_name "id"
        delete.command :client do |client|
          client.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            deleted_client = repo.delete(id)

            puts "#{deleted_client.id}#{$separator}#{deleted_client.name}" if deleted_client # standard:disable Style/GlobalVars
          end
        end

        delete.desc "Delete Institution"
        delete.arg_name "id"
        delete.command :institution do |institution|
          institution.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            deleted_institution = repo.delete(id)

            puts "#{deleted_institution.id}#{$separator}#{deleted_institution.name}" if deleted_institution # standard:disable Style/GlobalVars
          end
        end

        delete.desc "Delete Network"
        delete.arg_name "id"
        delete.command :network do |network|
          network.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            deleted_network = repo.delete(id)

            puts "#{deleted_network.id}#{$separator}#{deleted_network.cidr}#{$separator}#{deleted_network.access}" if deleted_network # standard:disable Style/GlobalVars
          end
        end

        delete.desc "Delete User"
        delete.arg_name "id"
        delete.command :user do |user|
          user.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            deleted_user = repo.delete(id)

            puts "#{deleted_user.id}#{$separator}#{deleted_user.name}" if deleted_user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
