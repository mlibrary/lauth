require "dotenv"
require "config"
require "hanami/api"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "lauth"

module Lauth
  module API
    Dotenv.load

    Config.setup do |config|
      config.const_name = "Settings"
      config.use_env = true
      config.env_prefix = "LAUTH_API"
      config.env_separator = "_"
      config.env_converter = :downcase
      config.env_parse_values = true
    end

    Config.load_and_set_settings(Config.setting_files(__dir__ + "/config", nil))

    class APP < Hanami::API
      get "/" do
        "This is the Lauth API, and our version is #{Lauth::VERSION}."
      end

      get "/clients" do
        client_repo = Lauth::API::Repositories::Client.new(BDD.rom)
        clients = []
        client_repo.clients.each do |client|
          clients << client.resource_object
        end
        clients.to_json
        # [clients.count].to_s
      end

      post "/clients" do
        client_repo = Lauth::API::Repositories::Client.new(BDD.rom)
        client = client_repo.create(params)
        client.resource_identifier_object.to_json
      end

      get "/users" do
        user_repo = Lauth::API::Repositories::User.new(BDD.rom)
        users = []
        user_repo.users.each do |user|
          users << user.resource_object
        end
        users.to_json
      end

      get "/users/:id" do |id|
        # The root user should always be present
        user_repo = Lauth::API::Repositories::User.new(BDD.rom)
        user = user_repo.user(params[:id])
        if user
          user.resource_object.to_json
        else
          {error: "User not found: #{params[:id]}"}
        end
      end
    end

    # Totally cheesy db stub; move to real config/boot
    class DB
      def self.rom
        @@rom ||= ::ROM.container(
          :sql,
          ENV.fetch("DATABASE_URL", "mysql2://mariadb/lauth?username=lauth&password=lauth")
        ) do |config|
          config.relation(:aa_user) do
            schema(infer: true)
          end
        end
      end
    end

    class BDD
      def self.rom
        @@rom ||= ::ROM.container(:sql, Settings.db.to_h) do |config|
          config.auto_registration("../lib/lauth/api/rom", namespace: "Lauth::API::ROM")
        end
      end
    end
  end
end
