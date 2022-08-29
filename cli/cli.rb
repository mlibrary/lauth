ENV["RACK_ENV"] ||= "development"

API_ROOT = File.expand_path("../../api", __FILE__)
require "yaml"
CONFIG = YAML.safe_load(File.open(File.join(API_ROOT, "settings.yml")))[ENV["RACK_ENV"]]

require "gli"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "lauth"

$LOAD_PATH.unshift(File.expand_path("..", __FILE__))
# commands_from("app")

module Lauth
  module CLI
    module APP
      extend GLI::App

      program_desc "Describe your application here"

      subcommand_option_handling :normal
      arguments :strict

      desc "Describe some switch here"
      switch [:s, :switch]

      desc "Describe some flag here"
      default_value "the default"
      arg_name "The name of the argument"
      flag [:f, :flagname]

      commands_from("app")

      pre do |global, command, options, args|
        # Pre logic here
        # Return true to proceed; false to abort and not call the
        # chosen command
        # Use skips_pre before a command to skip this block
        # on that command only
        true
      end

      post do |global, command, options, args|
        # Post logic here
        # Use skips_post before a command to skip this
        # block on that command only
      end

      on_error do |exception|
        # Error logic here
        # return false to skip default error handling
        true
      end
    end

    class BDD
      def self.rom
        uri = case ENV["RACK_ENV"]
        when "development"
          "http://localhost:9292"
        when "test"
          "http://localhost:9191"
        when "compose"
          "http://api.lauth.local:9292"
        when "ci"
          "http://0.0.0.0:9292"
        else
          "http://api.lauth.local:9292"
        end

        # @@rom ||= ::ROM.container(:http, uri: uri, handlers: :json) do |config|
        @@rom ||= ::ROM.container(:http, uri: uri, handlers: :handlers) do |config|
          config.auto_registration("../lib/lauth/cli/rom", namespace: "Lauth::CLI::ROM")
        end
      end
    end

    def self.client_repo
      Lauth::CLI::ROM::Repositories::Client.new(Lauth::CLI::BDD.rom)
    end
  end
end
