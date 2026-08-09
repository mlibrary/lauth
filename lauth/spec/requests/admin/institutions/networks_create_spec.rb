# frozen_string_literal: true

RSpec.describe "POST /api/v1/institutions/:id/networks", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }
  let(:json_headers) { authorization.merge("CONTENT_TYPE" => "application/json") }

  it "requires authentication" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), "CONTENT_TYPE" => "application/json"

    expect(last_response.status).to eq(401)
  end

  it "creates a canonicalized network batch with the default access switch" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.17/24", "198.51.100.0/25"]), json_headers

    expect(last_response.status).to eq(201)
    networks = JSON.parse(last_response.body, symbolize_names: true).fetch(:networks)
    expect(networks.map { |network| network[:dlpsCIDRAddress] }).to eq(["192.0.2.0/24", "198.51.100.0/25"])
    expect(networks).to all(include(inst: 7, dlpsAccessSwitch: "allow"))
  end

  it "accepts an explicit deny access switch" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"], accessSwitch: "deny"), json_headers

    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body, symbolize_names: true).dig(:networks, 0, :dlpsAccessSwitch)).to eq("deny")
  end

  it "rejects invalid batches without creating any networks" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24", "192.0.2.0/33"]), json_headers

    expect(last_response.status).to eq(400)
    expect(Lauth::Repositories::NetworkRepo.new.networks.to_a).to be_empty
  end

  it "rejects duplicate canonical CIDRs" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24", "192.0.2.17/24"]), json_headers

    expect(last_response.status).to eq(400)
  end

  it "allows overlapping networks across institutions" do
    Factory[:institution, uniqueIdentifier: 7]
    Factory[:institution, uniqueIdentifier: 8]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    post "/api/v1/institutions/8/networks", JSON.generate(cidrs: ["192.0.2.0/25"]), json_headers

    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body, symbolize_names: true).dig(:networks, 0, :inst)).to eq(8)
  end

  it "returns not found for an inactive institution" do
    Factory[:institution, :soft_deleted, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    expect(last_response.status).to eq(404)
  end
end
