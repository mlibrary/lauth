RSpec.describe Lauth::Ops::Authorize do

  it do
    request = Lauth::Access::Request.new(
      uri: "/user/",
      user: "cool_dude",
      client_ip: "111.2.3.4"
    )

    op = Lauth::Ops::Authorize.new(request: request)
    expect(op.call).to be_a_kind_of AuthorizationResult
  end

end
