RSpec.describe "/authorized delegation", type: [:request, :database] do
  let!(:user) { Factory[:user, userid: "lauth-allowed"] }
  before(:each) do
    setup_coll("secret", has_grant: false, pub: false)
    setup_coll("public", has_grant: false, pub: true)
    setup_coll("extra",  has_grant: true,  pub: false)
    setup_coll("both",   has_grant: true,  pub: true)
    target = setup_coll("target", has_grant: true,  pub: false)
    Factory[:location, dlpsPath: "/delegated", collection: target]
  end

  context "when authorized" do
    it "is allowed" do
      body = request(as: user)
      expect(body[:determination]).to eq "allowed"
    end

    it "lists public collections" do
      body = request(as: user)
      expect(body[:public_collections]).to contain_exactly "public"
    end

    it "lists authorized collections" do
      body = request(as: user)
      expect(body[:authorized_collections]).to contain_exactly *%w(target extra both)
    end
  end

  context "when unauthorized" do
    it "is allowed" do
      body = request(as: "")
      expect(body[:determination]).to eq "allowed"
    end

    it "lists public collections" do
      body = request(as: "")
      expect(body[:public_collections]).to contain_exactly *%w(public both)
    end

    it "lists (zero) authorized collections" do
      body = request(as: "")
      expect(body[:authorized_collections]).to be_empty
    end
  end

  private

  def setup_coll(name, has_grant:, pub:)
    collection = Lauth::Fab::Collection.create(
      uniqueIdentifier: name,
      dlpsAuthzType: "d",
      dlpsPartlyPublic: pub ? "t" : "f",
      dlpsClass: "foo",
    )

    if has_grant
      Factory[:grant, :for_user, user: user, collection: collection]
    end

    collection
  end

  # @return [Hash] the response body after json parsing
  def request(as: )
    get "/authorized", {user: as.to_s, uri: "/delegated" }
    JSON.parse(last_response.body, symbolize_names: true)
  end

end
