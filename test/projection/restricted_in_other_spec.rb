RSpec.describe "Projecting another collection in restricted space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space, but adopts the rules for
  # another restricted collection.
  #
  # good_user has been granted access to /projection/private/
  # another_good_user has been granted access to /projection/private-also/
  # /projection/private-also/but-not-really/ is rewritten to /projection/private/

  include AuthUsers

  context "when logged in as an authorized user of the base collection (good_user)" do
    let(:website) do
      Faraday.new(
        url: TestSite::URL,
        headers: { "X-Forwarded-User" => good_user }
      )
    end

    it "allows access to the area projected into good_user's collection" do
      response = website.get("/projection/private-also/but-not-really/")
      expect(response.status).to eq HttpCodes::OK
    end
    it "denies access to another_good_user's private collection" do
      response = website.get("/projection/private-also/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
    it "allows access to good_user's private collection" do
      response = website.get("/projection/private/")
      expect(response.status).to eq HttpCodes::OK
    end
  end

  context "when logged in as an authorized user of the projected collection (another_good_user)" do
    let(:website) do
      Faraday.new(
        url: TestSite::URL,
        headers: { "X-Forwarded-User" => another_good_user }
      )
    end

    it "denies access to the area projected into good_user's collection" do
      response = website.get("/projection/private-also/but-not-really/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
    it "allows access to another_good_user's private collection" do
      response = website.get("/projection/private-also/")
      expect(response.status).to eq HttpCodes::OK
    end
    it "denies access to good_user's private collection" do
      response = website.get("/projection/private/")
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end
  end

  private

  def website
    @website ||= Faraday.new(TestSite::URL)
  end
end
