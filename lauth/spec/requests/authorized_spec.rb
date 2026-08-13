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

  it "denies an unknown resource" do
    get "/authorized", {user: "lauth-allowed", uri: "/missing"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body, symbolize_names: true)).to include(determination: "denied")
  end

  it "denies an invalid client IP" do
    Factory[:collection, :restricted_by_username]

    get "/authorized", {user: "lauth-allowed", uri: "/restricted-by-username/", ip: "invalid"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body, symbolize_names: true)).to include(determination: "denied")
  end

  it "denies a legacy management collection" do
    collection = Factory[:collection, uniqueIdentifier: "legacy", dlpsAuthzType: "m"]
    Factory[:location, collection: collection, dlpsPath: "/legacy%"]

    get "/authorized", {user: "lauth-allowed", uri: "/legacy"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body, symbolize_names: true)).to include(determination: "denied")
  end

  it "matches the administrative access result for a normal collection" do
    user = Factory[:user, userid: "parity-user"]
    collection = Factory[:collection, :restricted_by_username, uniqueIdentifier: "parity-normal"]
    Factory[:location, collection: collection, dlpsPath: "/parity-normal%"]
    Factory[:grant, :for_user, user: user, collection: collection]

    get "/authorized", {user: user.userid, uri: "/parity-normal/"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
    public_result = JSON.parse(last_response.body)

    get "/api/v1/access", {userid: user.userid, collection: collection.uniqueIdentifier}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
    admin_result = JSON.parse(last_response.body)

    expect(public_result).to eq(admin_result)
  end

  it "matches the administrative access result for a delegated collection" do
    user = Factory[:user, userid: "delegated-parity-user"]
    target = Factory[
      :collection, :delegated, uniqueIdentifier: "parity-target", dlpsClass: "parity"
    ]
    public = Factory[
      :collection, :delegated, uniqueIdentifier: "parity-public", dlpsClass: "parity",
      dlpsPartlyPublic: "t"
    ]
    Factory[:location, collection: target, dlpsPath: "/parity-target%"]
    Factory[:grant, :for_user, user: user, collection: target]

    get "/authorized", {user: user.userid, uri: "/parity-target/"}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
    public_result = JSON.parse(last_response.body)

    get "/api/v1/access", {userid: user.userid, collection: target.uniqueIdentifier}, {"HTTP_AUTHORIZATION" => "Bearer VGhlIEhvYmJpdAo="}
    admin_result = JSON.parse(last_response.body)

    expect(public_result).to eq(admin_result)
    expect(public_result.fetch("public_collections")).to include(public.uniqueIdentifier)
  end
end
