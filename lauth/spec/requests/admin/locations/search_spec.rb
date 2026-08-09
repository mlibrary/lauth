# frozen_string_literal: true

RSpec.describe "/api/v1/locations", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "requires at least one search value" do
    get "/api/v1/locations", {}, authorization

    expect(last_response.status).to eq(400)
  end

  it "searches locations by path and server together" do
    matching = Factory[:location, dlpsPath: "/books", dlpsServer: "server.example"]
    Factory[:location, dlpsPath: "/books", dlpsServer: "other.example"]
    Factory[:location, dlpsPath: "/journals", dlpsServer: "server.example"]

    get "/api/v1/locations", {path: "/books", server: "server.example"}, authorization

    expect(last_response).to be_successful
    location = JSON.parse(last_response.body, symbolize_names: true).fetch(:locations).fetch(0)
    expect(location).to include(
      coll: matching.coll,
      dlpsPath: "/books",
      dlpsServer: "server.example",
      dlpsDeleted: "f"
    )
  end
end
