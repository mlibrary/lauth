# frozen_string_literal: true

RSpec.describe "/api/v1/institutions", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "requires authentication" do
    get "/api/v1/institutions", {organizationName: "Michigan"}

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "unauthorized", "message" => "Authentication is required"}
    )
  end

  it "returns active institutions matching the organization name" do
    Factory[:institution, uniqueIdentifier: 7, organizationName: "Michigan Library"]
    Factory[:institution, uniqueIdentifier: 8, organizationName: "Other University"]
    Factory[:institution, :soft_deleted, uniqueIdentifier: 9, organizationName: "Michigan Deleted"]

    get "/api/v1/institutions", {organizationName: "Michigan"}, authorization

    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      institutions: [
        {uniqueIdentifier: 7, organizationName: "Michigan Library"}
      ]
    )
  end

  it "treats only the asterisk as a wildcard" do
    Factory[:institution, uniqueIdentifier: 7, organizationName: "Michigan Library"]
    Factory[:institution, uniqueIdentifier: 8, organizationName: "Michigan%Library"]

    get "/api/v1/institutions", {organizationName: "Michigan*Library"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:institutions].map { |row| row[:uniqueIdentifier] }).to eq([7, 8])
  end

  it "rejects a missing search value" do
    get "/api/v1/institutions", {}, authorization

    expect(last_response.status).to eq(400)
  end
end
