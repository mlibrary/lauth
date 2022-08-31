require "./cli"
require "dotenv"
require "rom-factory"

Dotenv.load

LAUTH_API_ROM = ::ROM.container(:sql, ENV["LAUTH_TEST_DB_URL"]) do |config|
  config.auto_registration("../lib/lauth/api/rom", namespace: "Lauth::API::ROM")
end

Factory = ROM::Factory.configure do |config|
  config.rom = LAUTH_API_ROM
end

factories_dir = File.expand_path("../../../../lib/lauth/api/factories", __FILE__)
Dir[factories_dir + "/*.rb"].sort.each { |file| require file }

require "database_cleaner/sequel"

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

# require "rack/test"
#
# include Rack::Test::Methods
#
# def app
#   Lauth::API.new
# end

BeforeAll do
  # puts "Before All"
end

AfterAll do
  # puts "After All"
end

Before do
  # puts "Before"
end

After do
  # puts "After"
end
