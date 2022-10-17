module Lauth
  module CLI
    module APP
      desc "Update Resource"
      long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
      )
      arg_name "Resource"
      command :update do |update|
        update.desc "Update Client"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :client do |client|
          client.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            updated_client = repo.update(id, attributes)

            puts "#{updated_client.id}#{$separator}#{updated_client.name}" if updated_client # standard:disable Style/GlobalVars
          end
        end

        update.desc "Update Collection"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :collection do |collection|
          collection.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Collection.new($rom) # standard:disable Style/GlobalVars
            updated_collection = repo.update(id, attributes)

            puts "#{updated_collection.id}#{$separator}#{updated_collection.name}" if updated_collection # standard:disable Style/GlobalVars
          end
        end

        update.desc "Update Group"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :group do |group|
          group.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Group.new($rom) # standard:disable Style/GlobalVars
            updated_group = repo.update(id, attributes)

            puts "#{updated_group.id}#{$separator}#{updated_group.name}" if updated_group # standard:disable Style/GlobalVars
          end
        end

        update.desc "Update Institution"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :institution do |institution|
          institution.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            updated_institution = repo.update(id, attributes)

            puts "#{updated_institution.id}#{$separator}#{updated_institution.name}" if updated_institution # standard:disable Style/GlobalVars
          end
        end

        update.desc "Update Network"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :network do |network|
          network.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            updated_network = repo.update(id, attributes)

            puts "#{updated_network.id}#{$separator}#{updated_network.cidr}#{$separator}#{updated_network.access}" if updated_network # standard:disable Style/GlobalVars
          end
        end

        update.desc "Update User"
        update.arg "id"
        update.arg "attributes", type: Hash
        update.command :user do |user|
          # user.desc "User ID"
          user.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            updated_user = repo.update(id, attributes)

            puts "#{updated_user.id}#{$separator}#{updated_user.name}" if updated_user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
