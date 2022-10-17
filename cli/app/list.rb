module Lauth
  module CLI
    module APP
      desc "List Resource"
      arg_name "Resource"
      command :list do |list|
        desc "Page List Size"
        list.flag [:pagesize], arg_name: "page_size", default_value: 10

        desc "Page Number"
        list.flag [:pagenumber], arg_name: "page_number", default_value: -1

        desc "Regulare Expression"
        list.flag [:regex], arg_name: "regular_expression", default_value: ".*"

        list.desc "List Clients"
        list.command :clients do |clients|
          clients.action do |global_options, options, args|
            # If you have any errors, just raise them
            # raise "that command made no sense" unless args

            repo = Lauth::CLI::Repositories::Client.new($rom) # standard:disable Style/GlobalVars
            listed_clients = repo.index

            listed_clients.each do |client|
              puts "#{client.id}#{$separator}#{client.name}" # standard:disable Style/GlobalVars
            end
          end
        end

        list.desc "List Institutions"
        list.command :institutions do |institutions|
          institutions.action do |global_options, options, args|
            # If you have any errors, just raise them
            # raise "that command made no sense" unless args

            repo = Lauth::CLI::Repositories::Institution.new($rom) # standard:disable Style/GlobalVars
            listed_institutions = repo.index

            listed_institutions.each do |institution|
              puts "#{institution.id}#{$separator}#{institution.name}" # standard:disable Style/GlobalVars
            end
          end
        end

        list.desc "List Networks"
        list.command :networks do |networks|
          networks.action do |global_options, options, args|
            # If you have any errors, just raise them
            # raise "that command made no sense" unless args

            repo = Lauth::CLI::Repositories::Network.new($rom) # standard:disable Style/GlobalVars
            listed_networks = repo.index

            listed_networks.each do |network|
              puts "#{network.id}#{$separator}#{network.cidr}#{$separator}#{network.access}" # standard:disable Style/GlobalVars
            end
          end
        end

        list.desc "List Users"
        list.command :users do |users|
          users.action do |global_options, options, args|
            # If you have any errors, just raise them
            # raise "that command made no sense" unless args

            repo = Lauth::CLI::Repositories::User.new($rom) # standard:disable Style/GlobalVars
            listed_users = repo.index

            listed_users.each do |user|
              puts "#{user.id}#{$separator}#{user.name}" # standard:disable Style/GlobalVars
            end
          end
        end
      end
    end
  end
end
