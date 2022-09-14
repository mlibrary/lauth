require "dotenv"
require "config"
require "hanami/api"
require "base64"

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
      module Authentication
        private

        def authorized!
          # puts env
          errors = '{"errors":[{"error":{"code":401,"msg":"Unauthorized"}}]}'
          halt(401, errors) unless env["HTTP_X_AUTH"] # User Anonymous
          plain = Base64.decode64(env["HTTP_X_AUTH"])
          username, password = plain.split(":")
          user_repo = Lauth::API::Repositories::User.new(BDD.rom)
          user = user_repo.read(username)
          halt(401, errors) unless user # User Unknown
          halt(401, errors) unless user.password == password # User Wrong Password
        end
      end

      helpers(Authentication)

      get "/" do
        "This is the Lauth API, and our version is #{Lauth::VERSION}."
      end

      # CLIENTS

      # index clients
      get "/clients" do
        authorized!
        repo = Lauth::API::Repositories::Client.new(BDD.rom)
        document = {}
        clients = []
        repo.index.each do |client|
          clients << client.resource_object
        end
        document[:data] = clients
        document.to_json
      end

      # create client
      post "/clients" do
        authorized!
        repo = Lauth::API::Repositories::Client.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        client = repo.create(document)

        if client
          document = {}
          document[:data] = client.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":403,"msg":"Forbidden"}}]}'
          halt(403, errors)
        end
      end

      # read client
      get "/clients/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Client.new(BDD.rom)
        client = repo.read(params[:id])

        if client
          document = {}
          document[:data] = client.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # update client
      put "/clients/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Client.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        client = repo.update(document)

        if client
          document = {}
          document[:data] = client.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # delete client
      delete "/clients/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Client.new(BDD.rom)
        client = repo.read(params[:id])

        if client
          repo.delete(params[:id])
          document = {}
          document[:data] = client.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # INSTITUTIONS

      # index institutions
      get "/institutions" do
        authorized!
        repo = Lauth::API::Repositories::Institution.new(BDD.rom)
        document = {}
        institutions = []
        repo.index.each do |institution|
          institutions << institution.resource_object
        end
        document[:data] = institutions
        document.to_json
      end

      # create institution
      post "/institutions" do
        authorized!
        repo = Lauth::API::Repositories::Institution.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        institution = repo.create(document)

        if institution
          document = {}
          document[:data] = institution.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":403,"msg":"Forbidden"}}]}'
          halt(403, errors)
        end
      end

      # read institution
      get "/institutions/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Institution.new(BDD.rom)
        institution = repo.read(params[:id])

        if institution
          document = {}
          document[:data] = institution.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # update institution
      put "/institutions/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Institution.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        institution = repo.update(document)

        if institution
          document = {}
          document[:data] = institution.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # delete institution
      delete "/institutions/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::Institution.new(BDD.rom)
        institution = repo.read(params[:id])

        if institution
          repo.delete(params[:id])
          document = {}
          document[:data] = institution.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # USERS

      # index users
      get "/users" do
        authorized!
        repo = Lauth::API::Repositories::User.new(BDD.rom)
        document = {}
        users = []
        repo.index.each do |user|
          users << user.resource_object
        end
        document[:data] = users
        document.to_json
      end

      # create user
      post "/users" do
        authorized!
        repo = Lauth::API::Repositories::User.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        user = repo.create(document)

        if user
          document = {}
          document[:data] = user.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":403,"msg":"Forbidden"}}]}'
          halt(403, errors)
        end
      end

      # read user
      get "/users/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::User.new(BDD.rom)
        user = repo.read(params[:id])

        if user
          document = {}
          document[:data] = user.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # update user
      put "/users/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::User.new(BDD.rom)
        document = JSON.parse(env["rack.input"].gets)
        user = repo.update(document)

        if user
          document = {}
          document[:data] = user.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
        end
      end

      # delete user
      delete "/users/:id" do |id|
        authorized!
        repo = Lauth::API::Repositories::User.new(BDD.rom)
        user = repo.delete(params[:id])

        if user
          document = {}
          document[:data] = user.resource_object
          document.to_json
        else
          errors = '{"errors":[{"error":{"code":404,"msg":"Not Found"}}]}'
          halt(404, errors)
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
