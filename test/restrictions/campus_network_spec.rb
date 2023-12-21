RSpec.describe "Access to resources restricted to a known network" do
  include BasicAuth

  let(:content) { "allowed by authorized network" }

  context "given a collection configured for 'ip' auth" do
    context "given an allowed network only" do
      it "allows an unknown user within the network" do
        response = request_from("10.1.16.22")
        expect(response.status).to eq HttpCodes::OK
        expect(response.body).to include content
      end

      it "denies an unknown user outside the network" do
        response = request_from("10.1.17.30")
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end

    context "given a denied enclave within an allowed network" do
      it "denies an unknown user within the enclave" do
        response = request_from("10.1.6.2")
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
      it "allows an unknown user outside the enclave" do
        response = request_from("10.1.6.44")
        expect(response.status).to eq HttpCodes::OK
        expect(response.body).to include content
      end
    end

    context "given an allowed enclave within a denied network" do
      it "allows an unknown user within the enclave" do
        response = request_from("10.1.7.14")
        expect(response.status).to eq HttpCodes::OK
        expect(response.body).to include content
      end
      it "denies an unknown user outside the enclave" do
        response = request_from("10.1.7.63")
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end

    context "given a denied network only" do
      it "denies an unknown user within the network" do
        response = request_from("10.1.17.2")
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end
  end

  private

  def website
    @website ||= Faraday.new(TestSite::URL)
  end

  # Request the location from the provided ip address
  # @param ip [String]
  # @return response
  def request_from(ip)
    website.get("/restricted-by-network/") do |req|
      # We set the bad user because it is a user without grants, and at present
      # we must supply a user with the apache config.
      req.headers["Authorization"] = basic_auth_bad_user
      req.headers["X-Client-IP"] = ip
    end
  end


end
