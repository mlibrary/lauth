require "faraday"
require "base64"

# standard:disable Naming/ConstantName
class HttpCodes
  OK = 200
  UNAUTHORIZED = 401
  FORBIDDEN = 403
end
# standard:enable Naming/ConstantName

module TestSite
  URL = ENV["TEST_URL_BASE"] || "http://www.lauth.local"
end

Dir[File.dirname(__FILE__) + "/support/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.example_status_persistence_file_path = ".example.status"

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
end
