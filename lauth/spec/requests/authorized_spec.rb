RSpec.describe "/authorized", type: [:request, :database] do
  # known resource, authorized user
  # unknown resource, authorized user
  # known resource, unauthorized user
  # unknown resource, unauthorized user

  # aa_user (User): lauth-allowed
  # aa_coll (Collection): lauth-by-username
  # coll_obj (Location): /restricted-by-username/
  # aa_may_access (Grant): lauth-allowed -> lauth-by-username: GOOD

  context "with an authorized user" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection] }

    it do
      get "/authorized", {user: "lauth-allowed", uri: "/restricted-by-username/"}
      body = JSON.parse(last_response.body, symbolize_names: true)

      expect(body).to eq({determination: "allowed"})
    end
  end
end
