# A set of examples for testing delegated mode, to aid in keeping hosted_spec
# and proxied_spec in sync.
#
# Requires the following context to be supplied:
#   let(:url) The url of the location to GET
#   let(:parsed_body) Extract the body from the response, as a hash. The response
#     is available to this block.
RSpec.shared_examples "delegated mode" do
  include AuthUsers
  include CollectionStringHelpers

  before(:all) do
    @website = Faraday.new(TestSite::URL)
  end

  context "when logged in as an authorized user" do
    subject(:response) do
      @website.get(url) do |req|
        req.headers["X-Forwarded-User"] = good_user
      end
    end
    it "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    it "lists the matching public collections" do
      list = parsed_body[public_column]
      expect(list).to match_collection_string_format
      expect(tokenize_collection_string(list))
        .to include "public-cats"
    end

    it "lists the matching authorized collections" do
      list = parsed_body[authorized_column]
      expect(list).to match_collection_string_format
      expect(tokenize_collection_string(list))
        .to include "target-cats", "extra-cats", "extra-public-cats"
    end
  end

  context "when not logged in" do
    subject(:response) { @website.get(url) }
    it "is OK" do
      expect(response.status).to eq HttpCodes::OK
    end

    it "lists the matching public collections" do
      list = parsed_body[public_column]
      expect(list).to match_collection_string_format
      expect(tokenize_collection_string(list))
        .to include "public-cats", "extra-public-cats"
    end

    it "lists the matching authorized collections" do
      list = parsed_body[authorized_column]
      expect(list).to eq ":"
    end
  end
end
