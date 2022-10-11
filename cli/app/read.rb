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
            client = repo.read(id).one

            puts "#{client.id}#{$separator}#{client.name}" if client # standard:disable Style/GlobalVars
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
            institution = repo.read(id).one

            puts "#{institution.id}#{$separator}#{institution.name}" if institution # standard:disable Style/GlobalVars
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
            user = repo.read(id).one

            puts "#{user.id}#{$separator}#{user.name}" if user # standard:disable Style/GlobalVars
          end
        end
      end
    end
  end
end
