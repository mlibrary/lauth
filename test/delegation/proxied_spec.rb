require_relative "delegated_mode"

# TODO: Currently skipped pending figuring out how to put the data into the headers.
RSpec.describe "A proxied application in delegated mode", :skip do
  # These are apps external to the web server, configured for reverse proxy.
  # They should receive identity and the authorized collections in forwarded
  # headers.

  include_examples "delegated mode" do
    let(:url) { "/app/proxied" }
    let(:parsed_body) do
      response.body
        .split("\n")
        .map { |s| s.split(":", 2) }
        .to_h
    end
  end
end
