# frozen_string_literal: true

RSpec.describe "GET /api/v1/collections/:id/grants", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "returns no grants when the collection has only deleted grants" do
    collection = Factory[:collection, uniqueIdentifier: "example"]
    Factory[:grant, collection: collection, dlpsDeleted: "t"]

    get "/api/v1/collections/example/grants", {}, authorization

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body, symbolize_names: true)[:grants]).to be_empty
  end

  it "returns not found for an unknown collection" do
    get "/api/v1/collections/missing/grants", {}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "collection not found"}
    )
  end
end
