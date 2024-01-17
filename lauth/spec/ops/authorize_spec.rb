RSpec.describe Lauth::Ops::Authorize do
  let(:grant_repo) { instance_double("Lauth::Repositories::GrantRepo") }
  let(:request) do
    Lauth::Access::Request.new(
      user: "cool_dude",
      uri: "/some/uri/",
      client_ip: "10.11.22.33"
    )
  end

  it "allows a request with a grant" do
    allow(grant_repo).to receive(:for).with(
      username: "cool_dude",
      uri: "/some/uri/",
      client_ip: "10.11.22.33"
    ).and_return([:somegrant])
    op = Lauth::Ops::Authorize.new(grant_repo: grant_repo, request: request)
    expect(op.call).to eq Lauth::Access::Result.new(determination: "allowed")
  end

  it "denies a request without any grants" do
    allow(grant_repo).to receive(:for).with(
      username: "cool_dude",
      uri: "/some/uri/",
      client_ip: "10.11.22.33"
    ).and_return([])
    op = Lauth::Ops::Authorize.new(grant_repo: grant_repo, request: request)
    expect(op.call).to eq Lauth::Access::Result.new(determination: "denied")
  end

end
