RSpec.describe "/authorized", type: [:request, :database] do
  # known resource, authorized user
  # unknown resource, authorized user
  # known resource, unauthorized user
  # unknown resource, unauthorized user

  # aa_user (User): lauth-allowed
  # aa_coll (Collection): lauth-user
  # coll_obj (Location): /user/
  # aa_may_access (Grant): lauth-allowed -> lauth-user: GOOD

  context "with an authorized user" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:collection) { Factory[:collection, :restricted_to_users, uniqueIdentifier: "lauth-user"] }
    let!(:grant) { Factory[:grant, user: user, collection: collection] }

    it do
      get "/authorized?user=lauth-allowed&uri=%2Fuser%2F"
      body = JSON.parse(last_response.body, symbolize_names: true)

      expect(body).to eq({determination: "allowed"})
    end
  end
end
