require "base64"

RSpec.describe "Access to resources restricted to named institution member" do
  include BasicAuth

  context "when logged in as an institution member" do
    it "is allowed" do
      response = website.get("/restricted-by-username/") do |req|
        req.headers["Authorization"] = basic_auth_inst_member
      end

      expect(response.status).to eq HttpCodes::OK
    end
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
