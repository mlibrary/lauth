RSpec.describe Lauth::Access::Request do
  it "can be created" do
    request = Lauth::Access::Request.new(
      uri: "/some-location/",
      user: "cool_dude",
      client_ip: "111.2.3.4"
    )

    expect(request.uri).to eq("/some-location/")
    expect(request.user).to eq("cool_dude")
    expect(request.client_ip).to eq("111.2.3.4")
  end
end
