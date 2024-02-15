RSpec.describe "Projecting public access in restricted space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space, but adopts the rules for
  # a public collection.

  include BasicAuth
  let(:content) { "public in projection scenarios" }

  context "when logged in as an authorized user" do
    let(:website) do
      Faraday.new(
        url: TestSite::URL,
        headers: { "X-Forwarded-User" => good_user }
      )
    end

    it "allows access to the public collection" do
      response = website.get("/projection/public/")
      expect(response.status).to eq HttpCodes::OK
      expect(response.body).to include content
    end
    it "allows access to the private collection" do
      response = website.get("/projection/private/but-not-really/")
      expect(response.status).to eq HttpCodes::OK
      expect(response.body).to include content
    end
  end
  context "when not logged in" do
    let(:website) { Faraday.new(TestSite::URL) }

    it "allows access to the public collection" do
      response = website.get("/projection/public/")
      expect(response.status).to eq HttpCodes::OK
      expect(response.body).to include content
    end
    it "allows access to the private collection" do
      response = website.get("/projection/private/but-not-really/")
      expect(response.status).to eq HttpCodes::OK
      expect(response.body).to include content
    end
  end

  private

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
