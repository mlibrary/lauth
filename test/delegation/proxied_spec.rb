RSpec.describe "A proxied application in delegated mode" do
  # These are apps external to the web server, configured for reverse proxy.
  # They should receive identity and the authorized collections in forwarded
  # headers.

  include AuthUsers
  context "when logged in as an authorized user" do
    subject(:response) do
      website.get("/app/proxied") do |req|
        req.headers["X-Forwarded-User"] = good_user
      end
    end
    xit "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    xit "lists the matching public collections" do
      expect(parse(response.body)["X-Public-Coll"]&.split(":"))
        .to contain_exactly 'public-cats'
    end

    xit "lists the matching authorized collections" do
      expect(parse(response.body)["X-Authzd-Coll"]&.split(":"))
        .to contain_exactly 'target-cats', 'extra-cats', 'extra-public-cats'
    end
  end

  context "when not logged in" do
    subject(:response) { website.get("/app/proxied") }
    xit "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    xit "lists the matching public collections" do
      expect(parse(response.body)["X-Public-Coll"]&.split(":"))
        .to contain_exactly 'domestic-cats', 'extra-public-cats'
    end

    xit "lists the matching authorized collections" do
      expect(parse(response.body)["X-Authzd-Coll"]&.split(":"))
        .to be_empty
    end
  end

  private

  def parse(response_body)
    response_body
      .split("\n")
      .map{|s| s.split(":", 2)}
      .to_h
  end

  def website
    @website ||= Faraday.new(TestSite::URL)
  end

end
