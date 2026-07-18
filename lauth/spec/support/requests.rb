# frozen_string_literal: true

require "rack/test"

RSpec.shared_context "with Rack::Test" do
  let(:app) { Hanami.app }
end

RSpec.shared_context "with Lauth::Persistence" do
  let(:rom) { Hanami.app["persistence.rom"] }
  let(:relations) { rom.relations }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :request
  config.include_context "with Rack::Test", type: :request
  config.include_context "with Lauth::Persistence", type: :database
end
