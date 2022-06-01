RSpec.describe "Access to public resources" do
  context "when using an off-campus computer" do
    context "when not logged in" do
      it "is allowed" do
        response = Faraday.get("http://www.lauth.local/public")
        expect(response).to be_success
      end
    end
  end
end
