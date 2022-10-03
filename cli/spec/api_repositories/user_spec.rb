RSpec.describe Lauth::API::Repositories::User do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:user) { repo.read("user") }

  it "is initialized with a single root user" do
    expect(repo.index.count).to eq(1)
    expect(repo.index.one.id).to eq("root")
  end

  it "has three users after calling the factory twice but factory returns the wrong users" do
    a_user = Factory[:user, userid: "a_user"]
    z_user = Factory[:user, userid: "z_user"]
    expect(repo.index.count).to eq(3)
    expect(repo.index.to_a.map(&:id)).to contain_exactly("root", "a_user", "z_user")
    expect(a_user.userid).to eq("a_user")
    expect(z_user.userid).not_to eq("z_user")
    expect(z_user.userid).to eq("a_user")
    expect(repo.read("a_user").id).to eq("a_user")
    expect(repo.read("z_user").id).to eq("z_user")
  end

  context "User" do
    before { Factory[:user, userid: "user", surname: "Name"] }

    describe "#id" do
      it "returns initialized value" do
        expect(user.id).to eq("user")
      end
    end

    describe "#name" do
      it "returns initialized value" do
        expect(user.name).to eq("Name")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(user.resource_object).to eq({type: "users", id: user.id.to_s, attributes: {name: user.name}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(user.resource_identifier_object).to eq({type: "users", id: user.id.to_s})
      end
    end
  end
end
