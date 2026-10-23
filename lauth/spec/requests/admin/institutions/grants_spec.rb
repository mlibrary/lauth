# frozen_string_literal: true

RSpec.describe "GET /api/v1/institutions/:id/grants", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "returns active grants and excludes deleted grants" do
    institution = Factory[:institution, uniqueIdentifier: 7]
    collection = Factory[:collection, uniqueIdentifier: "example"]
    active_grant = Factory[
      :grant, collection: collection, inst: institution.uniqueIdentifier,
      lastModifiedBy: "admin"
    ]
    Factory[
      :grant, collection: collection, inst: institution.uniqueIdentifier,
      dlpsDeleted: "t"
    ]

    get "/api/v1/institutions/7/grants", {}, authorization

    expect(last_response.status).to eq(200)
    grants = JSON.parse(last_response.body, symbolize_names: true)[:grants]
    expect(grants.size).to eq(1)
    expect(grants.first[:uniqueIdentifier]).to eq(active_grant.uniqueIdentifier)
    expect(grants.first[:lastModifiedBy]).to eq("admin")
  end

  it "returns not found for an unknown institution" do
    get "/api/v1/institutions/999/grants", {}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "institution not found"}
    )
  end
end
