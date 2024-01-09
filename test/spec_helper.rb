require "faraday"
require "base64"

# standard:disable Naming/ConstantName
class HttpCodes
  OK = 200
  UNAUTHORIZED = 401
  FORBIDDEN = 403
end
# standard:enable Naming/ConstantName

module AuthUsers
  def bad_user
    "lauth-denied"
  end

  def good_user
    "lauth-allowed"
  end

  def inst_user
    "lauth-inst-member"
  end
end

module BasicAuth
  include AuthUsers

  def basic_auth_bad_user
    "Basic #{Base64.urlsafe_encode64("#{bad_user}:lauth-denied")}"
  end

  def basic_auth_good_user
    "Basic #{Base64.urlsafe_encode64("#{good_user}:lauth-allowed")}"
  end

  def basic_auth_inst_member
    "Basic #{Base64.urlsafe_encode64("#{inst_user}:lauth-inst-member")}"
  end
end

module TestSite
  URL = ENV["TEST_URL_BASE"] || "http://www.lauth.local"
end

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
