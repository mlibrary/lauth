require "bundler/setup"

# require "hanami/api"
require "rom"
require "rom-sql"
require "rom-repository"

require_relative "lauth/entities"
require_relative "lauth/relations"
# require_relative "lauth/mappers"
# require_relative "lauth/commands"
require_relative "lauth/repositories"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "lauth"

module Lauth
  # class API < Hanami::API
  #   get "/" do
  #     "This is the Lauth API, and our version is #{Lauth::VERSION}."
  #   end
  #
  #   get "/users/:id" do |id|
  #     # The root user should always be present
  #     users = DB.rom.relations[:aa_user]
  #     user = users.where(userid: params[:id]).one
  #     user ||= {error: "User not found: #{params[:id]}"}
  #     json(user)
  #   end
  # end

  # Totally cheesy db stub; move to real config/boot
  # class DB
  #   def self.rom
  #     @@rom ||= ROM.container(
  #       :sql,
  #       ENV.fetch("DATABASE_URL", "mysql2://mariadb/lauth?username=lauth&password=lauth")
  #     ) do |config|
  #       config.relation(:aa_user) do
  #         schema(infer: true)
  #       end
  #     end
  #   end
  # end

  # SERVER

  def self.client_repo
    @client_repo ||= lauth::Repositories::Client.new(container)
  end

  def self.container
    return @container unless @container.nil?
    configuration = config
    configuration.auto_registration("./lauth/")
    @container = ROM.container(configuration)
  end

  def self.config
    @config ||= ROM::Configuration.new(:sql, "sqlite::memory", {}) do |config|
      config.default.create_table(:clients) do
        primary_key :id
        column :name, String, null: false
      end
    end
  end
end
