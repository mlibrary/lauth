RSpec.describe "Yabeda.lauth.create_count" do
  include Rack::Test::Methods

  def app
    Lauth::API::APP.new
  end

  # let!(:user) { Factory[:user, userid: "user", userPassword: "password"] }
  let(:headers) { {"HTTP_X_AUTH" => Base64.encode64("user:password").chomp} }

  it "resource clients" do
    expect { post "/clients", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.create_count)
      .with_tags(resource: "clients")
      .by(1)
  end

  it "resource institutions" do
    expect { post "/institutions", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.create_count)
      .with_tags(resource: "institutions")
      .by(1)
  end

  it "resource users" do
    expect { post "/users", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.create_count)
      .with_tags(resource: "users")
      .by(1)
  end
end
