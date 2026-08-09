# frozen_string_literal: true

RSpec.describe "POST /api/v1/institutions", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }
  let(:json_headers) { authorization.merge("CONTENT_TYPE" => "application/json") }

  it "requires authentication" do
    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"), "CONTENT_TYPE" => "application/json"

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "unauthorized", "message" => "Authentication is required"}
    )
  end

  it "creates an active institution" do
    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"), json_headers

    expect(last_response.status).to eq(201)
    institution = JSON.parse(last_response.body, symbolize_names: true).fetch(:institution)
    expect(institution).to include(uniqueIdentifier: be_a(Integer), organizationName: "Example University")

    get "/api/v1/institutions", {organizationName: "Example University"}, authorization
    expect(JSON.parse(last_response.body, symbolize_names: true)[:institutions]).to include(institution)
  end

  it "rejects a missing, blank, or non-string organization name" do
    [JSON.generate({}), JSON.generate(organizationName: "   "), JSON.generate(organizationName: 7)].each do |body|
      post "/api/v1/institutions", body, json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(error: include(code: "invalid_parameter"))
    end
  end

  it "allows duplicate active organization names" do
    Factory[:institution, organizationName: "Example University"]

    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"), json_headers

    expect(last_response).to be_created
  end
end
