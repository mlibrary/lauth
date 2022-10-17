RSpec.describe "Yabeda.lauth.update_count" do
  include Rack::Test::Methods

  def app
    Lauth::API::APP.new
  end

  # let!(:user) { Factory[:user, userid: "user", userPassword: "password"] }
  let(:headers) { {"HTTP_X_AUTH" => Base64.encode64("user:password").chomp} }

  it "resource clients" do
    expect { put "/clients/1", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.update_count)
      .with_tags(resource: "clients")
      .by(1)
  end

  it "resource collections" do
    expect { put "/collections/michigan", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.update_count)
      .with_tags(resource: "collections")
      .by(1)
  end

  it "resource institutions" do
    expect { put "/institutions/michigan", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.update_count)
      .with_tags(resource: "institutions")
      .by(1)
  end

  it "resource networks" do
    expect { put "/networks/1", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.update_count)
      .with_tags(resource: "networks")
      .by(1)
  end

  it "resource users" do
    expect { put "/users/user", {}, headers }
      .to increment_yabeda_counter(Yabeda.lauth.update_count)
      .with_tags(resource: "users")
      .by(1)
  end
end
