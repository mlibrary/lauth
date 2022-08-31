module Lauth
  module CLI
    module APP
      desc "Describe list here"
      arg_name "Describe arguments to list here"
      command :list do |c|
        c.desc "Describe a switch to list"
        c.switch :s

        c.desc "Describe a flag to list"
        c.default_value "default"
        c.flag :f
        c.action do |global_options, options, args|
          # Your command logic

          # If you have any errors, just raise them
          # raise "that command made no sense"
          client_repo = Lauth::CLI::ROM::Repositories::Client.new($rom) # standard:disable Style/GlobalVars

          client_repo.clients.each do |client|
            puts client.name.to_s
          end
        end
      end
    end
  end
end
