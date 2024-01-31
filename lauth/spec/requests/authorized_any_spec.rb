RSpec.describe "/authorized by username or client-ip", type: [:request, :database] do
  let!(:collection) { Factory[:collection, :restricted_by_username_or_client_ip] }

  # Setup networks, institution, and grant the instutition access to the collection
  before(:each) do
    institution = Factory[:institution]
    Factory[ :network, :for_institution, institution: institution,
      dlpsAccessSwitch: "allow", dlpsCIDRAddress: "10.1.16.0/24" ]
    Factory[ :network, :for_institution, institution: institution,
      dlpsAccessSwitch: "deny", dlpsCIDRAddress: "10.1.17.0/24" ]
    Factory[:grant, :for_institution, institution: institution, collection: collection]
  end

  context "with an authorized individual" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:user_grant) { Factory[:grant, :for_user, user: user, collection: collection] }

    it "is allowed within an allowed network" do
      expect(request(from: "10.1.16.1", as: user)).to include(determination: "allowed")
    end
    it "is allowed within a denied network" do
      expect(request(from: "10.1.17.1", as: user)).to include(determination: "allowed")
    end
    it "is allowed outside of any known network" do
      expect(request(from: "10.1.18.1", as: user)).to include(determination: "allowed")
    end
  end

  context "with an anonymous user" do
    it "is allowed within an allowed network" do
      expect(request(from: "10.1.16.1", as: "")).to include(determination: "allowed")
    end
    it "is denied within a denied network" do
      expect(request(from: "10.1.17.1", as: "")).to include(determination: "denied")
    end
    it "is denied outside of any known network" do
      expect(request(from: "10.1.18.1", as: "")).to include(determination: "denied")
    end
  end

  private

  # Request the location from the provided ip address
  # @param ip [String]
  # @return [Hash] the response body after json parsing
  def request(from:, as:)
    get "/authorized", {user: as.to_s, uri: "/restricted-by-username-or-client-ip", ip: from}
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
