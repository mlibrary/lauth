require "./cli"
require "dotenv"
require "rom-factory"
require "database_cleaner/sequel"

Dotenv.load

MYSQL_DB = {
  adapter: ENV["LAUTH_API_DB_ADAPTER"] || :mysql2,
  host: ENV["LAUTH_API_DB_HOST"] || "localhost",
  port: ENV["LAUTH_API_DB_PORT"] || 3306,
  database: ENV["LAUTH_API_DB_DATABASE"] || "test",
  user: ENV["LAUTH_API_DB_USER"] || "root",
  password: ENV["LAUTH_API_DB_PASSWORD"] || "",
  encoding: ENV["LAUTH_API_DB_ENCODING"] || "utf8mb4"
}.freeze

MYSQL_CMD = "mysql --user=#{MYSQL_DB[:user]} --host=#{MYSQL_DB[:host]} --port=#{MYSQL_DB[:port]} --password=#{MYSQL_DB[:password]}  #{MYSQL_DB[:database]}".freeze

puts "MYSQL_DB  : " + MYSQL_DB.to_s
puts "MYSQL_CMD : " + MYSQL_CMD.to_s

LAUTH_API_ROM = ::ROM.container(:sql, MYSQL_DB) do |config|
  config.auto_registration("../lib/lauth/api/rom", namespace: "Lauth::API::ROM")
end

Factory = ROM::Factory.configure do |config|
  config.rom = LAUTH_API_ROM
end

factories_dir = File.expand_path("../../../../lib/lauth/api/factories", __FILE__)
Dir[factories_dir + "/*.rb"].sort.each { |file| require file }

DatabaseCleaner.strategy = :truncation

BeforeAll do
  puts `./bin/lauth --user=root --password="!none" --route=http://api.lauth.local:9292 initconfig --force`
  puts `cat ~/.lauth.rc`
  `#{MYSQL_CMD} < ../db/drop-keys.sql 2> /dev/null`
  DatabaseCleaner.clean
  `#{MYSQL_CMD} < ../db/root.sql 2> /dev/null`
  `#{MYSQL_CMD} < ../db/keys.sql 2> /dev/null`
end

AfterAll do
  `#{MYSQL_CMD} < ../db/drop-keys.sql 2> /dev/null`
  DatabaseCleaner.clean
  `#{MYSQL_CMD} < ../db/root.sql 2> /dev/null`
  `#{MYSQL_CMD} < ../db/keys.sql 2> /dev/null`
end

# NOTE: Around will mask Before and After a.k.a. XOR
# Around do |scenario, block|
#   # DatabaseCleaner.cleaning(&block)
# end

Before do
  DatabaseCleaner.start
end

After do |scenario|
  `#{MYSQL_CMD} < ../db/drop-keys.sql 2> /dev/null`
  DatabaseCleaner.clean
  `#{MYSQL_CMD} < ../db/root.sql 2> /dev/null`
  `#{MYSQL_CMD} < ../db/keys.sql 2> /dev/null`
end
