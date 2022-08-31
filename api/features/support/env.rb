require "./api"

require "rom-factory"

Factory = ROM::Factory.configure do |config|
  config.rom = Lauth::API::BDD.rom
end

factories_dir = File.expand_path("../../../../lib/lauth/api/factories", __FILE__)
Dir[factories_dir + "/*.rb"].sort.each { |file| require file }

require "database_cleaner/sequel"

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

require "rack/test"

include Rack::Test::Methods # standard:disable Style/MixinUsage

def app
  Lauth::API::APP.new
end

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
