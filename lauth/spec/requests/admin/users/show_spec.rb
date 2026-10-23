# frozen_string_literal: true

RSpec.describe "GET /api/v1/users/:userid", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "returns active grants and excludes deleted grants" do
    user = Factory[:user, userid: "alice"]
    collection = Factory[:collection, uniqueIdentifier: "example"]
    active_grant = Factory[
      :grant, collection: collection, userid: user.userid, lastModifiedBy: "admin"
    ]
    Factory[:grant, collection: collection, userid: user.userid, dlpsDeleted: "t"]

    get "/api/v1/users/alice", {}, authorization

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body, symbolize_names: true)
    expect(body[:grants].size).to eq(1)
    expect(body[:grants].first[:uniqueIdentifier]).to eq(active_grant.uniqueIdentifier)
    expect(body[:grants].first[:lastModifiedBy]).to eq("admin")
  end

  it "returns not found for an unknown user" do
    get "/api/v1/users/missing", {}, authorization

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "user not found"}
    )
  end
end
