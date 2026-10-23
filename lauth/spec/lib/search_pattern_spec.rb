# frozen_string_literal: true

RSpec.describe Lauth::SearchPattern do
  describe ".wildcard" do
    it "wraps text in a contains pattern" do
      expect(described_class.wildcard("books")).to eq("%books%")
    end

    it "converts only the application wildcard" do
      expect(described_class.wildcard("books*archive")).to eq("%books%archive%")
    end

    it "escapes SQL wildcard characters and backslashes" do
      expect(described_class.wildcard("100%_\\path")).to eq("%100\\%\\_\\\\path%")
    end
  end
end
