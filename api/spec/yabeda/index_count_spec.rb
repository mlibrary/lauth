RSpec.describe "Yabeda.lauth.index_count" do
  include Rack::Test::Methods

  def app
    Lauth::API::APP.new
  end

  # let!(:user) { Factory[:user, userid: "user", userPassword: "password"] }
  let(:headers) { {"HTTP_X_AUTH" => Base64.encode64("user:password").chomp} }

  it "resource clients" do
    expect { get "/clients", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "clients")
      .by(1)
  end

  it "resource collections" do
    expect { get "/collections", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "collections")
      .by(1)
  end

  it "resource groups" do
    expect { get "/groups", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "groups")
      .by(1)
  end

  it "resource institutions" do
    expect { get "/institutions", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "institutions")
      .by(1)
  end

  it "resource networks" do
    expect { get "/networks", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "networks")
      .by(1)
  end

  it "resource users" do
    expect { get "/users", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.index_count)
      .with_tags(resource: "users")
      .by(1)
  end
end
