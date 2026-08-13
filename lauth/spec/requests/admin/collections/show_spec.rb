# frozen_string_literal: true

RSpec.describe "GET /api/v1/collections/:id", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "shows an active collection and excludes deleted grants" do
    collection = Factory[:collection, uniqueIdentifier: "example"]
    Factory[:grant, collection: collection, dlpsDeleted: "t"]

    get "/api/v1/collections/example", {}, authorization

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body, symbolize_names: true)
    expect(body[:collection]).to include(uniqueIdentifier: "example")
    expect(body[:grants]).to be_empty
  end

  it "returns not found for an unknown collection" do
    get "/api/v1/collections/missing", {}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "collection not found"}
    )
  end
end
