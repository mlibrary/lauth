# frozen_string_literal: true

RSpec.describe "administrative repository entities", type: :database do
  it "returns collection entities" do
    collection = Factory[:collection, uniqueIdentifier: "entity-collection"]
    collection_repo = Lauth::Repositories::CollectionRepo.new

    expect(collection_repo.find(collection.uniqueIdentifier)).to be_a(Lauth::Collection)
    expect(collection_repo.search_by_identifier("entity-collection")).to all(be_a(Lauth::Collection))
  end

  it "returns institution entities" do
    institution = Factory[:institution, organizationName: "Entity Institution"]
    institution_repo = Lauth::Repositories::InstitutionRepo.new

    expect(institution_repo.find(institution.uniqueIdentifier)).to be_a(Lauth::Institution)
    expect(institution_repo.search_by_organization_name("Entity Institution"))
      .to all(be_a(Lauth::Institution))
  end

  it "returns network entities" do
    institution = Factory[:institution]
    Factory[:network, :for_institution, institution: institution, dlpsCIDRAddress: "192.0.2.0/24"]
    network_repo = Lauth::Repositories::NetworkRepo.new

    expect(network_repo.for_institution(institution.uniqueIdentifier)).to all(be_a(Lauth::Network))
    expect(network_repo.search_by_ip("192.0.2.1")).to all(be_a(Lauth::Network))
  end

  it "returns location entities" do
    Factory[:location, dlpsPath: "/entity-path%", dlpsServer: "entity.example"]
    location_repo = Lauth::Repositories::LocationRepo.new

    expect(location_repo.search_by_path("entity-path")).to all(be_a(Lauth::Location))
    expect(location_repo.search_by_server("entity.example")).to all(be_a(Lauth::Location))
  end

  it "returns user and institution membership entities" do
    user = Factory[:user, userid: "entity-user"]
    Factory[:institution_membership, user: user]
    user_repo = Lauth::Repositories::UserRepo.new
    membership_repo = Lauth::Repositories::InstitutionMembershipRepo.new

    expect(user_repo.find(user.userid)).to be_a(Lauth::User)
    expect(membership_repo.for_user(user.userid)).to all(be_a(Lauth::InstitutionMembership))
  end
end
