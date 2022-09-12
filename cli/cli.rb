require "gli"
require "base64"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "lauth"

$LOAD_PATH.unshift(File.expand_path("..", __FILE__))
# commands_from("app")

module Lauth
  module CLI
    module APP
      extend GLI::App

      config_file ".lauth.rc"

      program_desc "A command-line interface (CLI) for managing data in the Library Authorization system."

      subcommand_option_handling :normal
      arguments :strict

      desc "Verbose"
      switch [:v, :verbose], negatable: false

      desc "Lauth API URL"
      flag [:r, :route], arg_name: "route", default_value: "http://127.0.0.1:9292"

      desc "Authorized user name"
      flag [:u, :user], arg_name: "user", default_value: "lauth"

      desc "Authorized user password"
      flag [:p, :password], arg_name: "password", default_value: "lauth", mask: true

      commands_from("app")

      pre do |global, command, options, args|
        # Pre logic here
        # Return true to proceed; false to abort and not call the
        # chosen command
        # Use skips_pre before a command to skip this block
        # on that command only
        credentials = Base64.encode64("#{global[:user]}:#{global[:password]}").chomp
        $rom = ::ROM.container(:http, uri: global[:route], headers: {X_AUTH: credentials}, handlers: :handlers) do |config| # standard:disable Style/GlobalVars
          config.auto_registration("../lib/lauth/cli/rom", namespace: "Lauth::CLI::ROM")
        end

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
  end
end
