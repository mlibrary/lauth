require_relative "delegated_mode"

RSpec.describe "A web server-hosted application in delegated mode" do
  # These are apps like CGI and mod_php. They should receive identity and the
  # authorized collections in the server environment.
  # These collections and grants are defined in delegation.sql

  include_examples "delegated mode" do
    let(:url) { "/hosted" }
    let(:parsed_body) do
      response.body
        .split("\n")
        .map { |s| s.split("=", 2) }
        .to_h
        .transform_values { |v| v.delete_prefix('"').delete_suffix('"') }
    end
  end
end
