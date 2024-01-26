RSpec.describe "A web server-hosted application in delegated mode" do
  # These are apps like CGI and mod_php. They should receive identity and the
  # authorized collections in the server environment.
  # These collections and grants are defined in delegation.sql
  include AuthUsers
  context "when logged in as an authorized user" do
    subject(:response) do
      website.get("/hosted") do |req|
        req.headers["X-Forwarded-User"] = good_user
      end
    end
    it "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    it "lists the matching public collections" do
      expect(parse_env(response.body)["PUBLIC_COLL"]&.split(":"))
        .to contain_exactly 'public-cats'
    end

    it "lists the matching authorized collections" do
      expect(parse_env(response.body)["AUTHZD_COLL"]&.split(":"))
        .to contain_exactly 'private-cats', 'extra-cats', 'foia-cats'
    end
  end

  context "when not logged in" do
    subject(:response) { website.get("/hosted") }
    it "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    it "lists the matching public collections" do
      expect(parse_env(response.body)["PUBLIC_COLL"]&.split(":"))
        .to contain_exactly 'public-cats', 'foia-cats'
    end

    it "lists the matching authorized collections" do
      expect(parse_env(response.body)["AUTHZD_COLL"]&.split(":"))
        .to be_empty
    end
  end

  private

  def parse_env(response_body)
    response_body
      .split("\n")
      .map{|s| s.split("=", 2)}
      .to_h
      .transform_values{|v| v.delete_prefix('"').delete_suffix('"')}
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end

end
