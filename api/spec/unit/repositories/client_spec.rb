RSpec.describe Lauth::API::ROM::Repositories::Client do
  let(:client_repo) { described_class.new(Lauth::API::BDD.rom) }

  describe "#clients" do
    it "empty" do
      expect(client_repo.clients.count).to eq(0)
    end

    context "one client" do
      let(:client_one) { Factory[:client] }

      before do
        client_one
      end

      it "contains one" do
        expect(client_repo.clients.count).to eq(1)
      end

      context "two clients" do
        let(:client_two) { Factory[:client] }

        before do
          client_two
        end

        it "contains two" do
          expect(client_repo.clients.count).to eq(2)
        end
      end
    end
  end
end
