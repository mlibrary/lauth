# frozen_string_literal: true

require "pathname"
SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV["HANAMI_ENV"] ||= "test"
require "hanami/prepare"
require "rom-factory"

require_relative "support/rspec"
require_relative "support/requests"
require_relative "support/database_cleaner"

if ENV["ROM_DEBUG"]
  Hanami.app["persistence.rom"].gateways[:default].use_logger Logger.new($stderr)
end

Factory = ROM::Factory.configure do |config|
  config.rom = Hanami.app["persistence.rom"]
end

Dir[File.dirname(__FILE__) + "/support/factories/*.rb"].each { |file| require file }
Dir[File.dirname(__FILE__) + "/support/fabricators/*.rb"].each { |file| require file }
