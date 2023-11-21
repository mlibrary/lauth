RSpec.describe Lauth::Ops::Authorize do
  it do
    request = Lauth::Access::Request.new(
      uri: "/user/",
      user: "cool_dude",
      client_ip: "111.2.3.4"
    )

    op = Lauth::Ops::Authorize.new(request: request)
    expect(op.call).to be_a Lauth::Access::Result
  end

  context "with an unknown user" do
    it "denies access" do
      request = Lauth::Access::Request.new(
        uri: "/user/",
        user: "",
        client_ip: "111.2.3.4"
      )

      result = Lauth::Ops::Authorize.call(request: request)

      expect(result.determination).to eq "denied"
    end
  end

  xcontext "with an authorized user" do
    it "denies access" do
      request = Lauth::Access::Request.new(
        uri: "/user/",
        user: "lauth-allowed",
        client_ip: "111.2.3.4"
      )

      result = Lauth::Ops::Authorize.call(request: request)

      expect(result.determination).to eq "allowed"
    end
  end
end
