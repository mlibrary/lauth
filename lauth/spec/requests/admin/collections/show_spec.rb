# frozen_string_literal: true

RSpec.describe "GET /api/v1/collections/:id", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "shows an active collection and excludes deleted grants" do
    collection = Factory[:collection, uniqueIdentifier: "example"]
    active_grant = Factory[:grant, collection: collection, lastModifiedBy: "admin"]
    Factory[:grant, collection: collection, dlpsDeleted: "t"]

    get "/api/v1/collections/example", {}, authorization

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body, symbolize_names: true)
    expect(body[:collection]).to include(uniqueIdentifier: "example")
    expect(body[:grants].size).to eq(1)
    expect(body[:grants].first[:uniqueIdentifier]).to eq(active_grant.uniqueIdentifier)
    expect(body[:grants].first[:lastModifiedBy]).to eq("admin")
  end

  it "returns not found for an unknown collection" do
    get "/api/v1/collections/missing", {}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "collection not found"}
    )
  end
end
