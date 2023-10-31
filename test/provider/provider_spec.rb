RSpec.describe "Lauth provider in Apache" do
  # This is probably a temporary test -- only verifies that we have wired up an authz provider
  context "when requesting the always-denied url" do
    it "is Forbidden" do
      response = website.get("/denied/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
