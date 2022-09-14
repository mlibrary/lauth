module Lauth
  module CLI
    module APP
      desc "Create Resource"
      arg_name "Resource"
      command :create do |create|
        create.desc "Create Client"
        create.arg "attributes", type: Hash
        create.command :client do |client|
          client.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            attributes = accepts[Hash].call(args[0])

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            new_client = repo.create(attributes)

            puts "#{new_client.id}#{$separator}#{new_client.name}" if new_client # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create Institution"
        create.arg "id"
        create.arg "attributes", type: Hash
        create.command :institution do |institution|
          institution.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            new_institution = repo.create(id, attributes)

            puts "#{new_institution.id}#{$separator}#{new_institution.name}" if new_institution # standard:disable Style/GlobalVars
          end
        end

        create.desc "Create User"
        create.arg "id"
        create.arg "attributes", type: Hash
        create.command :user do |user|
          # user.desc "User ID"
          user.action do |global_options, options, args|
            # If you have any errors, just raise them
            raise "that command made no sense" unless args
            id = args[0]
            attributes = accepts[Hash].call(args[1])

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            new_user = repo.create(id, attributes)

            puts "#{new_user.id}#{$separator}#{new_user.name}" if new_user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
