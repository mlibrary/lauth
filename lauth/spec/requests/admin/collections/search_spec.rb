# frozen_string_literal: true

RSpec.describe "/api/v1/collections", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "requires authentication" do
    get "/api/v1/collections", {id: "ampo20*"}

    expect(last_response.status).to eq(401)
  end

  it "searches active identifiers with an application wildcard" do
    Factory[:collection, uniqueIdentifier: "herb1ic"]
    Factory[:collection, uniqueIdentifier: "ampo20"]
    Factory[:collection, uniqueIdentifier: "ampo20-dev"]
    Factory[:collection, uniqueIdentifier: "herb1ic-dev"]
    Factory[:collection, :soft_deleted, uniqueIdentifier: "ampo20-deleted"]

    get "/api/v1/collections", {id: "ampo20*"}, authorization

    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body, symbolize_names: true)).to eq(
      collections: [
        {uniqueIdentifier: "ampo20"},
        {uniqueIdentifier: "ampo20-dev"}
      ]
    )
  end

  it "treats SQL wildcard characters as literals" do
    Factory[:collection, uniqueIdentifier: "ampo20-%"]
    Factory[:collection, uniqueIdentifier: "ampo20-dev"]

    get "/api/v1/collections", {id: "ampo20-%"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:collections]).to eq(
      [{uniqueIdentifier: "ampo20-%"}]
    )
  end

  it "rejects a missing id" do
    get "/api/v1/collections", {}, authorization

    expect(last_response.status).to eq(400)
  end
end
