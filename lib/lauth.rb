# Outside dependencies
require "rubygems"
require "gli"
require "hanami/api"
require "rom"
require "rom-sql"
require "rom-repository"
# require "mysql2"

# Lauth Module
require_relative "lauth/version"

require_relative "lauth/entities"

require_relative "lauth/relations"
# require_relative "lauth/mappers"
# require_relative "lauth/commands"

require_relative "lauth/repositories"

require_relative "lauth/app"
require_relative "lauth/service"

module Lauth
  extend GLI::App

  config_file ".lauth.rc"

  program_desc "Michigan Library Authentication Command Line Client"
  program_long_desc "A git like command line client"

  version VERSION
  subcommand_option_handling :normal
  arguments :strict

  desc "Specify the base URL of the LAUTH REST API"
  arg "base", :optional
  default_value "http://127.0.0.1:9292"
  flag [:b, :base]

  desc "Specify the bearer token to access the LAUTH REST API"
  arg "token", :optional
  default_value "anonymous"
  flag [:t, :token]

  pre do |global_options, command, options, args|
    $connection = Service::Connection.new({base: global_options[:base], token: global_options[:token]}) # standard:disable Style/GlobalVars
    true
  end

  commands_from("lauth")

  # CLIENT

  def self.client_container
    return @client_container unless @client_container.nil?
    configuration = client_config
    configuration.auto.registration("./lib/lauth/cli/")
    @client_container
  end

  def self.client_config
    @client_config ||= ROM::Configuration.new(:http, uri: "http://127.0.0.1:9292", handlers: :json) do |config|
    end
  end

  # SERVER

  def self.client_repo
    @client_repo ||= lauth::Repositories::Client.new(container)
  end

  def self.container
    return @container unless @container.nil?
    configuration = config
    configuration.auto_registration("./lib/lauth/")
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
