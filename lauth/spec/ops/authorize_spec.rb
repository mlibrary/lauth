RSpec.describe Lauth::Ops::Authorize, type: :database do
  it do
    request = Lauth::Access::Request.new(
      uri: "/restricted-by-username/",
      user: "cool_dude",
      client_ip: "111.2.3.4"
    )

    op = Lauth::Ops::Authorize.new(request: request)
    expect(op.call).to be_a Lauth::Access::Result
  end

  context "with an unknown user" do
    it "denies access" do
      request = Lauth::Access::Request.new(
        uri: "/restricted-by-username/",
        user: "",
        client_ip: "111.2.3.4"
      )

      result = Lauth::Ops::Authorize.call(request: request)

      expect(result.determination).to eq Lauth::Determination::Denied
    end
  end

  context "with an authorized user" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:grant) { Factory[:grant, user: user, collection: collection] }

    it "allows access" do
      request = Lauth::Access::Request.new(
        uri: "/restricted-by-username/",
        user: "lauth-allowed",
        client_ip: "111.2.3.4"
      )

      result = Lauth::Ops::Authorize.new(request: request).call

      expect(result.determination).to eq Lauth::Determination::Allowed
    end
  end
end
