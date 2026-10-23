# frozen_string_literal: true

RSpec.describe "GET /api/v1/access", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "requires authentication" do
    get "/api/v1/access", {userid: "alice", collection: "example"}

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "unauthorized", "message" => "Authentication is required"}
    )
  end

  it "allows a user with a direct grant to a normal collection" do
    collection = Factory[:collection, uniqueIdentifier: "example"]
    user = Factory[:user, userid: "alice"]
    Factory[:grant, :for_user, user: user, collection: collection]

    get "/api/v1/access", {userid: "alice", collection: "example"}, authorization

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq(
      "determination" => "allowed",
      "authorized_collections" => [],
      "public_collections" => []
    )
  end

  it "denies a user without a grant to a normal collection" do
    Factory[:collection, uniqueIdentifier: "example"]

    get "/api/v1/access", {userid: "alice", collection: "example"}, authorization

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq(
      "determination" => "denied",
      "authorized_collections" => [],
      "public_collections" => []
    )
  end

  it "reports authorized and public collections for delegated access" do
    delegated = Factory[
      :collection, :delegated, uniqueIdentifier: "delegated", dlpsClass: "example",
      dlpsPartlyPublic: "t"
    ]
    granted = Factory[
      :collection, :delegated, uniqueIdentifier: "granted", dlpsClass: "example",
      dlpsPartlyPublic: "t"
    ]
    Factory[
      :collection, :delegated, uniqueIdentifier: "public-only", dlpsClass: "example",
      dlpsPartlyPublic: "t"
    ]
    user = Factory[:user, userid: "alice"]
    Factory[:grant, :for_user, user: user, collection: granted]

    get "/api/v1/access", {userid: "alice", collection: delegated.uniqueIdentifier}, authorization

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq(
      "determination" => "allowed",
      "authorized_collections" => ["granted"],
      "public_collections" => ["delegated", "public-only"]
    )
  end

  it "passes an optional IP into access evaluation" do
    Factory[:collection, uniqueIdentifier: "example"]

    get "/api/v1/access", {userid: "alice", collection: "example", ip: "192.0.2.1"}, authorization

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body).fetch("determination")).to eq("denied")
  end

  it "requires a collection" do
    get "/api/v1/access", {userid: "alice"}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "collection not found"}
    )
  end

  it "requires a user ID" do
    Factory[:collection, uniqueIdentifier: "example"]

    get "/api/v1/access", {collection: "example"}, authorization

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "invalid_parameter", "message" => "userid is required"}
    )
  end

  it "rejects an invalid IP" do
    Factory[:collection, uniqueIdentifier: "example"]

    get "/api/v1/access", {userid: "alice", collection: "example", ip: "invalid"}, authorization

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "invalid_parameter", "message" => "ip must be an IPv4 address"}
    )
  end
end
