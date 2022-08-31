require "dotenv"
require "gli"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "lauth"

$LOAD_PATH.unshift(File.expand_path("..", __FILE__))
# commands_from("app")

module Lauth
  module CLI
    Dotenv.load

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
        @@rom ||= ::ROM.container(:http, uri: ENV["LAUTH_CLI_API_URL"], handlers: :handlers) do |config|
          config.auto_registration("../lib/lauth/cli/rom", namespace: "Lauth::CLI::ROM")
        end
      end
    end

    def self.client_repo
      Lauth::CLI::ROM::Repositories::Client.new(Lauth::CLI::BDD.rom)
    end
  end
end
