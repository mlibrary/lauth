require "bundler/setup"

require "hanami/api"

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "lauth"

module Lauth
  class API < Hanami::API
    get "/" do
      "This is the Lauth API, and our version is #{Lauth::VERSION}."
    end

    get "/users/:id" do |id|
      # The root user should always be present
      users = DB.rom.relations[:aa_user]
      user = users.where(userid: params[:id]).one
      user ||= { error: "User not found: #{params[:id]}" }
      json(user)
    end
  end

  # Totally cheesy db stub; move to real config/boot
  class DB
    def self.rom
      @@rom ||= ROM.container(
        :sql,
        ENV.fetch("DATABASE_URL", "mysql2://mariadb/lauth?username=lauth&password=lauth")
      ) do |config|
        config.relation(:aa_user) do
          schema(infer: true)
        end
      end
    end
  end
end
