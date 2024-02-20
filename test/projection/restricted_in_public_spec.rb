RSpec.describe "Projecting restricted access in public space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in public space, but adopts the rules for
  # a restricted collection.

  include BasicAuth

  context "when logged in as an authorized user" do
    let(:website) do
      Faraday.new(
        url: TestSite::URL,
        headers: { "X-Forwarded-User" => good_user }
      )
    end

    it "allows access to the projected-private area in the public collection" do
      response = website.get("/projection/public/but-not-really/")
      expect(response.status).to eq HttpCodes::OK
    end
    it "allows access to the public collection" do
      response = website.get("/projection/public/")
      expect(response.status).to eq HttpCodes::OK
    end
    it "allows access to the private collection" do
      response = website.get("/projection/private/")
      expect(response.status).to eq HttpCodes::OK
    end
  end

  context "when not logged in" do
    let(:website) { Faraday.new(TestSite::URL) }

    it "denies access to the projected-private area in the public collection" do
      response = website.get("/projection/public/but-not-really/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
    it "allows access to the public collection" do
      response = website.get("/projection/public/")
      expect(response.status).to eq HttpCodes::OK
    end
    it "denies access to the private collection" do
      response = website.get("/projection/private/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
  end

  private

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
