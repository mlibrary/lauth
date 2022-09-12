RSpec.describe Lauth::API::Repositories::User do
  let(:user_repo) { described_class.new(Lauth::API::BDD.rom) }

  it "has only one user" do
    expect(user_repo.users.count).to eq(1)
  end

  it "has a single user with id root" do
    expect(user_repo.users.one.id).to eq("root")
  end

  describe "#users" do
    context "new user" do
      let(:user_one) { Factory[:user] }

      before do
        user_one
      end

      it "contains a new user" do
        expect(user_repo.users.count).to eq(2)
      end

      context "another new user" do
        let(:user_two) { Factory[:user] }

        before do
          user_two
        end

        it "contains another new user" do
          expect(user_repo.users.count).to eq(3)
        end
      end
    end
  end
end
