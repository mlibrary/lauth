# frozen_string_literal: true

RSpec.describe "POST /api/v1/institutions/:id/networks", type: [:request, :database] do
  let(:authorization) { {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="} }
  let(:json_headers) { authorization.merge("CONTENT_TYPE" => "application/json") }

  it "requires authentication" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), "CONTENT_TYPE" => "application/json"

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "unauthorized", "message" => "Authentication is required"}
    )
  end

  it "rejects an invalid bearer token" do
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]),
      "CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Bearer invalid"

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "unauthorized", "message" => "Authentication is required"}
    )
  end

  it "creates a canonicalized network batch with the default access switch" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.17/24", "198.51.100.0/25"]), json_headers

    expect(last_response.status).to eq(201)
    networks = JSON.parse(last_response.body, symbolize_names: true).fetch(:networks)
    expect(networks.map { |network| network[:dlpsCIDRAddress] }).to eq(["192.0.2.0/24", "198.51.100.0/25"])
    expect(networks).to all(include(inst: 7, dlpsAccessSwitch: "allow"))
  end

  it "returns the exact network creation envelope" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.17/24"]), json_headers

    response = JSON.parse(last_response.body, symbolize_names: true)
    expect(response.keys).to eq([:networks])
    expect(response[:networks].size).to eq(1)
    expect(response[:networks].first.keys).to contain_exactly(
      :uniqueIdentifier, :dlpsCIDRAddress, :dlpsAddressStart, :dlpsAddressEnd,
      :dlpsAccessSwitch, :inst, :lastModifiedTime
    )
    expect(response[:networks].first).to include(
      dlpsCIDRAddress: "192.0.2.0/24", dlpsAccessSwitch: "allow", inst: 7
    )
  end

  it "accepts an explicit deny access switch" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"], accessSwitch: "deny"), json_headers

    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body, symbolize_names: true).dig(:networks, 0, :dlpsAccessSwitch)).to eq("deny")
  end

  it "rejects malformed JSON and a non-object top-level value" do
    ["{", "[]", "null", '"networks"'].each do |body|
      post "/api/v1/institutions/7/networks", body, json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
        error: include(code: "invalid_parameter")
      )
    end
  end

  it "rejects missing, empty, and wrong-type cidrs" do
    Factory[:institution, uniqueIdentifier: 7]

    [JSON.generate({}), JSON.generate(cidrs: []), JSON.generate(cidrs: "192.0.2.0/24"), JSON.generate(cidrs: [7])].each do |body|
      post "/api/v1/institutions/7/networks", body, json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
        error: include(code: "invalid_parameter")
      )
    end
  end

  it "rejects an invalid access switch" do
    Factory[:institution, uniqueIdentifier: 7]

    [{accessSwitch: ""}, {accessSwitch: "block"}, {accessSwitch: 7}].each do |options|
      body = {cidrs: ["192.0.2.0/24"]}.merge(options)
      post "/api/v1/institutions/7/networks", JSON.generate(body), json_headers

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body, symbolize_names: true)).to include(
        error: {code: "invalid_parameter", message: "accessSwitch must be allow or deny"}
      )
    end
  end

  it "rejects invalid batches without creating any networks" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24", "192.0.2.0/33"]), json_headers

    expect(last_response.status).to eq(400)
    expect(Lauth::Repositories::NetworkRepo.new.networks.to_a).to be_empty
  end

  it "creates a mixed batch when one exact CIDR is already active" do
    Factory[:institution, uniqueIdentifier: 7]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["198.51.100.0/24", "192.0.2.17/24"]), json_headers

    expect(last_response.status).to eq(201)
    networks = JSON.parse(last_response.body, symbolize_names: true).fetch(:networks)
    expect(networks.map { |network| network[:dlpsCIDRAddress] }).to eq(["198.51.100.0/24", "192.0.2.0/24"])
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "198.51.100.0/24", dlpsDeleted: "f").count).to eq(1)
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "192.0.2.0/24", dlpsDeleted: "f").count).to eq(2)
  end

  it "creates separate rows for duplicate canonical CIDRs in one request" do
    Factory[:institution, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24", "192.0.2.17/24"]), json_headers

    expect(last_response.status).to eq(201)
    networks = JSON.parse(last_response.body, symbolize_names: true).fetch(:networks)
    expect(networks.map { |network| network[:dlpsCIDRAddress] }).to eq(["192.0.2.0/24", "192.0.2.0/24"])
    expect(networks.map { |network| network[:uniqueIdentifier] }.uniq.size).to eq(2)
  end

  it "creates an exact active CIDR for another institution" do
    Factory[:institution, uniqueIdentifier: 7, organizationName: "First Institution"]
    Factory[:institution, uniqueIdentifier: 8, organizationName: "Second Institution"]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    post "/api/v1/institutions/8/networks", JSON.generate(cidrs: ["192.0.2.17/24"]), json_headers

    expect(last_response.status).to eq(201)
    network = JSON.parse(last_response.body, symbolize_names: true).fetch(:networks).first
    expect(network).to include(dlpsCIDRAddress: "192.0.2.0/24", dlpsAccessSwitch: "allow", inst: 8)
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsAddressStart: 3221225984, dlpsAddressEnd: 3221226239, dlpsDeleted: "f").count).to eq(2)
  end

  it "creates an exact active CIDR on the opposite access switch" do
    Factory[:institution, uniqueIdentifier: 7]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"], accessSwitch: "allow"), json_headers

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"], accessSwitch: "deny"), json_headers

    expect(last_response.status).to eq(201)
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsAddressStart: 3221225984, dlpsAddressEnd: 3221226239, dlpsDeleted: "f").select_map(:dlpsAccessSwitch))
      .to contain_exactly("allow", "deny")
  end

  it "allows containment and other non-exact overlaps" do
    Factory[:institution, uniqueIdentifier: 7]
    Factory[:institution, uniqueIdentifier: 8]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    post "/api/v1/institutions/8/networks", JSON.generate(cidrs: ["192.0.2.0/25"]), json_headers

    expect(last_response.status).to eq(201)
  end

  it "allows repeated recreation of a soft-deleted CIDR" do
    Factory[:institution, uniqueIdentifier: 7]
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers
    expect(last_response.status).to eq(201)
    Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "192.0.2.0/24").update(dlpsDeleted: "t")

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers
    expect(last_response.status).to eq(201)
    Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "192.0.2.0/24", dlpsDeleted: "f").update(dlpsDeleted: "t")

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers
    expect(last_response.status).to eq(201)
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "192.0.2.0/24", dlpsDeleted: "t").count).to eq(2)
    expect(Lauth::Repositories::NetworkRepo.new.networks.dataset.where(dlpsCIDRAddress: "192.0.2.0/24", dlpsDeleted: "f").count).to eq(1)
  end

  it "returns not found for an inactive institution" do
    Factory[:institution, :soft_deleted, uniqueIdentifier: 7]

    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "institution not found"}
    )
  end

  it "returns not found when the institution is missing" do
    post "/api/v1/institutions/7/networks", JSON.generate(cidrs: ["192.0.2.0/24"]), json_headers

    expect(last_response.status).to eq(404)
    expect(JSON.parse(last_response.body)).to eq(
      "error" => {"code" => "not_found", "message" => "institution not found"}
    )
  end
end
