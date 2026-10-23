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

  it "rejects an invalid bearer token with the exact error envelope" do
    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"),
      "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Bearer invalid"

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

  it "returns the exact creation envelope" do
    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"), json_headers

    response = JSON.parse(last_response.body, symbolize_names: true)
    expect(response.keys).to eq([:institution])
    expect(response[:institution].keys).to contain_exactly(:uniqueIdentifier, :organizationName)
    expect(response[:institution]).to include(organizationName: "Example University", uniqueIdentifier: be_a(Integer))
  end

  it "rejects malformed JSON" do
    post "/api/v1/institutions", "{", json_headers

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
      error: include(code: "invalid_parameter")
    )
  end

  it "rejects a non-object top-level JSON value" do
    ["[]", "null", '"institution"'].each do |body|
      post "/api/v1/institutions", body, json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
        error: include(code: "invalid_parameter")
      )
    end
  end

  it "rejects a missing, blank, or non-string organization name with an exact envelope" do
    [
      [JSON.generate({}), 'key not found: "organizationName"'],
      [JSON.generate(organizationName: "   "), "organizationName is required"],
      [JSON.generate(organizationName: 7), "organizationName is required"]
    ].each do |body, message|
      post "/api/v1/institutions", body, json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
        error: {code: "invalid_parameter", message: message}
      )
    end
  end

  it "allows duplicate active organization names" do
    Factory[:institution, organizationName: "Example University"]

    post "/api/v1/institutions", JSON.generate(organizationName: "Example University"), json_headers

    expect(last_response).to be_created
  end
end
