require "base64"

RSpec.describe "Access to resources restricted to specific users" do
  include BasicAuth

  context "when using an off-campus computer" do
    context "when not logged in" do
      it "results in authentication request" do
        response = website.get("/user/")
        expect(response.status).to eq HttpCodes::UNAUTHORIZED
      end
    end

    context "when logged in as an unauthorized user" do
      xit "is forbidden" do
        response = website.get("/user/") do |req|
          req.headers["Authorization"] = basic_auth_bad_user
        end

        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
