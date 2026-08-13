# frozen_string_literal: true

RSpec.describe "/api/v1/networks", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }

  it "searches by an IP address" do
    network = Factory[:network, dlpsCIDRAddress: "192.0.2.0/24"]
    Factory[:network, dlpsCIDRAddress: "198.51.100.0/24"]
    Factory[:network, dlpsCIDRAddress: "192.0.2.0/24", dlpsDeleted: "t"]

    get "/api/v1/networks", {ip: "192.0.2.10"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:networks].map { |row| row[:uniqueIdentifier] }).to eq([network.uniqueIdentifier])
    expect(JSON.parse(last_response.body, symbolize_names: true)[:networks].first.keys).not_to include(:dlpsDNSName, :dlpsDeleted)
  end

  it "searches by a dotted prefix" do
    network = Factory[:network, dlpsCIDRAddress: "192.0.2.0/24"]

    get "/api/v1/networks", {prefix: "192.0.2"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:networks].map { |row| row[:uniqueIdentifier] }).to include(network.uniqueIdentifier)
  end

  it "searches CIDRs by range overlap" do
    network = Factory[:network, dlpsCIDRAddress: "192.0.2.0/25"]

    get "/api/v1/networks", {cidr: "192.0.2.64/26"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:networks].map { |row| row[:uniqueIdentifier] }).to include(network.uniqueIdentifier)
  end

  it "searches an explicit range" do
    network = Factory[:network, dlpsCIDRAddress: "192.0.2.0/24"]

    get "/api/v1/networks", {rangeStart: "192.0.2.10", rangeEnd: "192.0.2.20"}, authorization

    expect(JSON.parse(last_response.body, symbolize_names: true)[:networks].map { |row| row[:uniqueIdentifier] }).to include(network.uniqueIdentifier)
  end

  it "requires exactly one search mode" do
    get "/api/v1/networks", {ip: "192.0.2.1", cidr: "192.0.2.0/24"}, authorization

    expect(last_response.status).to eq(400)
  end

  it "rejects an invalid IP" do
    get "/api/v1/networks", {ip: "invalid"}, authorization

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to include(
      "error" => include("code" => "invalid_parameter")
    )
  end

  it "rejects an invalid range address" do
    get "/api/v1/networks", {rangeStart: "invalid", rangeEnd: "192.0.2.20"}, authorization

    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)).to include(
      "error" => include("code" => "invalid_parameter")
    )
  end
end
