RSpec.describe "/authorized", type: [:request, :database] do
  # known resource, authorized user
  # unknown resource, authorized user
  # known resource, unauthorized user
  # unknown resource, unauthorized user

  # aa_user (User): lauth-allowed
  # aa_coll (Collection): lauth-by-username
  # coll_obj (Location): /restricted-by-username/
  # aa_may_access (Grant): lauth-allowed -> lauth-by-username: GOOD

  context "with an authorized individual" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection] }

    it do
      get "/authorized", {user: "lauth-allowed", uri: "/restricted-by-username/"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
      body = JSON.parse(last_response.body, symbolize_names: true)

      expect(body).to include(determination: "allowed")
    end
  end

  context "with an authorized group" do
    let!(:user) { Factory[:user, userid: "lauth-group-member"] }
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:group) {
      Factory[:group]
      relations.groups.last
    }
    let!(:group_membership) { Factory[:group_membership, group: group, user: user] }
    let!(:grant) { Factory[:grant, :for_group, group: group, collection: collection] }

    it do
      get "/authorized", {user: "lauth-group-member", uri: "/restricted-by-username/"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}

      body = JSON.parse(last_response.body, symbolize_names: true)
      expect(body).to include(determination: "allowed")
    end
  end
end
