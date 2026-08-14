# frozen_string_literal: true

RSpec.describe Lauth::Repositories::GroupMembershipRepo, type: :database do
  subject(:repo) { described_class.new }

  it "recognizes an active membership" do
    user = Factory[:user, userid: "manager"]
    group = Factory[:group, uniqueIdentifier: 7]
    Factory[:group_membership, user: user, group: group]

    expect(repo.member?(user.userid, group.uniqueIdentifier)).to be(true)
  end

  it "does not recognize a deleted membership" do
    user = Factory[:user, userid: "former-manager"]
    group = Factory[:group, uniqueIdentifier: 8]
    Factory[:group_membership, :soft_deleted, user: user, group: group]

    expect(repo.member?(user.userid, group.uniqueIdentifier)).to be(false)
  end

  it "does not recognize a membership for another user or group" do
    user = Factory[:user, userid: "manager"]
    group = Factory[:group, uniqueIdentifier: 9]
    Factory[:group_membership, user: user, group: group]

    expect(repo.member?("other-user", group.uniqueIdentifier)).to be(false)
    expect(repo.member?(user.userid, 10)).to be(false)
  end
end
