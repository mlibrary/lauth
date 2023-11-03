RSpec.describe "Access to resources restricted to a known network" do
  # These resources should require that the client IP address is within an
  # authorized range (implying use of an authorized institution's computing
  # resources).
  #
  # We should test inside and outside of a contiguous range and within a denied
  # subnet inside a larger network.
  # We test inside and outside of a contiguous range and within a denied
  # subnet inside a larger network.
  #
  # Thus, there are three cases
  # in_range?   in_subnet?
  # yes         no
  # yes         yes
  # no          n/a
  #
  # outer   inner
  # allow  allow "law school can access regular campus stuff
  # allow  deny  "block some stupid law school computer
  # deny   allow "let the law school access more stuff
  # deny   deny  "no.
  #
  # Additionally, we should test that the ip range code is bypassed for a
  # user that is logged in. This can be done by

  # TODO:
  # so here's what we need:
  # an institution in aa_inst
  # a collection in aa_coll.
  # a 'location' in aa_coll_obj that actually points to our test site (lit-ip)...?
  # two network entries:
  #   1. big allowed one
  #   2. smaller denied one bisecting [1]
  # an aa_may_access entry that specifies coll, inst; leaves userid, user_group null
  # (and an institution granted access to the collection),

  let(:ip_content) { "allowed by authorized network" }
  let(:path) { "/restricted-by-network/" }

  # for a collection configured for ip auth
  # a known user who is a member of an institution
  # that has access to the collection
  # given they are outside the configured networks,
  # then they are denied

  context "given a collection open to a campus network" do

    it "is allowed within the campus network" do
      response = site.get(path) { |req| req.headers["X-Client-IP"] = "10.1.16.44" }
      expect(response.status).to eq HttpCodes::OK
      expect(response.body).to include ip_content
    end

    it "is denied outside the campus network" do
      response = site.get(path) { |req| req.headers["X-Client-IP"] = "10.1.8.30" }
      expect(response.status).to eq HttpCodes::FORBIDDEN
    end

  end

  xit "does not deny an authorized user" do
    response = site.get("/user/") { |req| req.headers["X-Client-IP"] = "17.17.17.1" }
    expect(response.status).to eq HttpCodes::OK
    expect(response.body).to include user_content
  end

  xit "is denied by default" do
    response = site.get(path) { |req| req.headers["X-Client-IP"] = "3.3.3.3" }
    expect(response.status).to eq HttpCodes::UNAUTHORIZED # forbidden?
  end

  xit "is allowd within specified ranges (<)" do
    response = site.get(path) { |req| req.headers["X-Client-IP"] = "6.1.1.1" }
    expect(response.status).to eq HttpCodes::OK
    expect(response.body).to include ip_content
  end

  # ensure assigning 6.1.1.2/32 respects the 32 cidr
  xit "is allowd within specified ranges (>)" do
    response = site.get(path) { |req| req.headers["X-Client-IP"] = "6.1.1.3" }
    expect(response.status).to eq HttpCodes::OK
    expect(response.body).to include ip_content
  end

  xit "is denied within nested allow>deny ranges" do
    response = site.get(path) { |req| req.headers["X-Client-IP"] = "6.1.1.2" }
    expect(response.status).to eq HttpCodes::UNAUTHORIZED # forbidden?
  end

  xit "is allowd within nested deny>allow ranges" do
    response = site.get(path) { |req| req.headers["X-Client-IP"] = "7.1.1.9" }
    expect(response.status).to eq HttpCodes::OK
    expect(response.body).to include ip_content
  end

  private

  def site
    @site ||= Faraday.new(TestSite::URL)
  end

end
