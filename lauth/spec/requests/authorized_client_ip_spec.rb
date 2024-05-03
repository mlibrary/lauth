RSpec.describe "/authorized by client-ip", type: [:request, :database] do
  let!(:institution) { Factory[:institution] }
  let!(:collection) { Factory[:collection, :restricted_by_client_ip] }
  let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

  context "(allow>none) given an allowed network only" do
    let!(:network) { create_network("allow", "10.1.16.0/24") }

    it "allows an unknown user within the network" do
      expect(request_from("10.1.16.2")).to include(determination: "allowed")
    end

    it "denies an unknown user outside the network" do
      expect(request_from("10.1.17.1")).to include(determination: "denied")
    end
  end

  context "(allow>allow) given an allowed enclave within an allowed network" do
    let!(:network) { create_network("allow", "10.1.6.0/24") }
    let!(:enclave) { create_network("allow", "10.1.6.8/29") }
    it "allows an unknown user within the enclave" do
      expect(request_from("10.1.6.9")).to include(determination: "allowed")
    end
    it "is allowed outside the enclave" do
      expect(request_from("10.1.6.7")).to include(determination: "allowed")
    end
  end

  context "(allow>deny) given a denied enclave within an allowed network" do
    let!(:network) { create_network("allow", "10.1.6.0/24") }
    let!(:enclave) { create_network("deny", "10.1.6.2/32") }
    it "denies an unknown user within the enclave" do
      expect(request_from("10.1.6.2")).to include(determination: "denied")
    end
    it "allows an unknown user outside the enclave" do
      expect(request_from("10.1.6.44")).to include(determination: "allowed")
    end
  end

  context "(deny>allow) given an allowed enclave within a denied network" do
    let!(:network) { create_network("deny", "10.1.7.0/24") }
    let!(:enclave) { create_network("allow", "10.1.7.8/29") }
    it "allows an unknown user within the enclave" do
      expect(request_from("10.1.7.14")).to include(determination: "allowed")
    end
    it "denies an unknown user outside the enclave" do
      expect(request_from("10.1.7.63")).to include(determination: "denied")
    end
  end

  context "(deny>deny) given a denied enclave within a denied network" do
    let!(:network) { create_network("deny", "10.1.17.0/24") }
    let!(:enclave) { create_network("deny", "10.1.17.8/29") }
    it "denies an unknown user within the enclave" do
      expect(request_from("10.1.17.12")).to include(determination: "denied")
    end
    it "denies an unknown user outside the enclave" do
      expect(request_from("10.1.17.63")).to include(determination: "denied")
    end
  end

  context "(deny>none) given a denied network only" do
    let!(:network) { create_network("deny", "10.1.17.0/24") }
    it "denies an unknown user within the network" do
      expect(request_from("10.1.17.2")).to include(determination: "denied")
    end
  end

  private

  # Convenience for building networks.
  # Requires 'institution' be set in a let block.
  # @param access [String] Either 'allow' or 'deny'
  # @param cidr [String] A IPv4 CIDR range. We attempt to mirror those ranges that
  #   are in db/network.sql for clarity.
  def create_network(access, cidr)
    Factory[
      :network, :for_institution, institution: institution,
      dlpsAccessSwitch: access, dlpsCIDRAddress: cidr
    ]
  end

  # Request the location from the provided ip address
  # @param ip [String]
  # @return [Hash] the response body after json parsing
  def request_from(ip)
    get "/authorized", {user: "", uri: "/restricted-by-client-ip", ip: ip}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
