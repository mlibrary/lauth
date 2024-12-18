require "base64"

RSpec.describe "Access to resources restricted to named group member" do
  include BasicAuth

  context "when logged in as a group member" do
    it "is allowed" do
      response = website.get("/restricted-by-username/") do |req|
        req.headers["Authorization"] = basic_auth_group_member
      end

      expect(response.status).to eq HttpCodes::OK
    end
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
