
RSpec.describe "/authorized", type: :request do
  # known resource, authorized user
  # unknown resource, authorized user
  # known resource, unauthorized user
  # unknown resource, unauthorized user

  context "with an authorized user" do
    it do
      get "/authorized?user=lauth-allowed&uri=%2Fuser%2F"
      body = JSON.parse(last_response.body, symbolize_names: true)
      expect(body).to eq({determination: "allowed"})
    end
  end
end
