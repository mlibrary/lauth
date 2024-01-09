RSpec.describe "Access to resources restricted to authenticated users or a known network" do
  include AuthUsers
  # These resources should require that either the user is authenticated or
  # that they are visiting from an authorized IP network range.
  let(:content) { "allowed by user authentication or authorized network" }

  context "given a collection configured for 'any' auth" do
    context "when inside an allowed network" do
      let(:ip) { "10.1.16.22" }
      it "allows an authorized user" do
        response = request(from: ip, as: good_user)
        expect(response.status).to eq HttpCodes::OK
      end
      it "allows an unauthorized user" do
        response = request(from: ip, as: bad_user)
        expect(response.status).to eq HttpCodes::OK
      end
      it "allows an unknown user" do
        response = request(from: ip, as: nil)
        expect(response.status).to eq HttpCodes::OK
      end
    end

    context "when inside a denied network" do
      let(:ip) { "10.1.17.2" }
      it "allows an authorized user" do
        response = request(from: ip, as: good_user)
        expect(response.status).to eq HttpCodes::OK
      end
      it "denies an unauthorized user" do
        response = request(from: ip, as: bad_user)
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
      it "denies an unknown user" do
        response = request(from: ip, as: nil)
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end

    # These are identical to the tests for /restricted-by-username/
    # except against a collection in 'any' mode.
    context "when outside any known network" do
      let(:ip) { "10.1.8.1" }
      it "allows an authorized user" do
        response = request(from: ip, as: good_user)
        expect(response.status).to eq HttpCodes::OK
      end
      it "denies an unauthorized user" do
        response = request(from: ip, as: bad_user)
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
      it "denies an unknown user" do
        response = request(from: ip, as: nil)
        expect(response.status).to eq HttpCodes::FORBIDDEN
      end
    end
  end

  private

  def website
    @website ||= Faraday.new(TestSite::URL)
  end

  # Request the location from the provided ip address
  # @param from [String] client ip
  # @param as [String] A BasicAuth user
  # @return response
  def request(from:, as:)
    website.get("/restricted-by-username-or-network/") do |req|
      req.headers["X-Forwarded-User"] = as if as
      req.headers["X-Client-IP"] = from if from
    end
  end
end
