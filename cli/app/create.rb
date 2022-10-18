module Lauth
  module CLI
    module APP
      desc "Create Resource"
      arg_name "Resource"
      command :create do |create|
        create.desc "Create Client"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<attributes>", type: Hash
        create.command :client do |client|
          client.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            attributes = accepts[Hash].call(args[0])

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            created_client = repo.create(attributes)

            puts "#{created_client.id}#{$separator}#{created_client.name}" if created_client # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create Collection"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<id>"
        create.arg "<attributes>", type: Hash
        create.command :collection do |collection|
          collection.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Collection.new($rom) # standard:disable Style/GlobalVars
            created_collection = repo.create(id, attributes)

            puts "#{created_collection.id}#{$separator}#{created_collection.name}" if created_collection # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create Group"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<id>"
        create.arg "<attributes>", type: Hash
        create.command :group do |group|
          group.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Group.new($rom) # standard:disable Style/GlobalVars
            created_group = repo.create(id, attributes)

            puts "#{created_group.id}#{$separator}#{created_group.name}" if created_group # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create Institution"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<id>"
        create.arg "<attributes>", type: Hash
        create.command :institution do |institution|
          institution.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            created_institution = repo.create(id, attributes)

            puts "#{created_institution.id}#{$separator}#{created_institution.name}" if created_institution # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create Network"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<id>"
        create.arg "<attributes>", type: Hash
        create.command :network do |network|
          network.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            created_network = repo.create(id, attributes)

            puts "#{created_network.id}#{$separator}#{created_network.cidr}#{$separator}#{created_network.access}" if created_network # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create User"
        create.long_desc %(
          Attributes are a comma separated list of colon separated key value pairs.

          name:<String>

          e.g. name:wolverine,year:1817,city:"Ann Arbor",state:Michigan
        )
        create.arg "<id>"
        create.arg "<attributes>", type: Hash
        create.command :user do |user|
          # user.desc "User ID"
          user.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            created_user = repo.create(id, attributes)

            puts "#{created_user.id}#{$separator}#{created_user.name}" if created_user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
