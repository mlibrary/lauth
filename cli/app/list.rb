module Lauth
  module CLI
    module APP
      desc "Describe list here"
      arg_name "Describe arguments to list here"
      command :list do |c|
        # c.desc "Describe a switch to list"
        # c.switch :s

        # c.desc "Describe a flag to list"
        # c.default_value "default"
        # c.flag :f

        c.action do |global_options, options, args|
          # Your command logic

          # If you have any errors, just raise them
          raise "that command made no sense" unless args

          case Array(args)[0]
          when "users"
            user_repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars

            user_repo.users.each do |user|
              puts user.id.to_s
            end
          when "clients"
            client_repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars

            client_repo.clients.each do |client|
              puts client.name.to_s
            end
          else
            raise "list #{args[0]} made no sense"
          end
        end
      end
    end
  end
end
