RSpec.describe Lauth::Determination do

  shared_examples "a determination" do |string|
    it "coerces string" do
      expect(determination).to eq string
    end

    it "coerces symbol" do
      expect(determination).to eq string.to_sym
    end

    it "equals itself" do
      expect(determination).to eq determination.class.new
    end

    it "prints as a string" do
      expect(determination.to_s).to eql string
    end

    it "is coerced to string" do
      expect(string).to eq determination
    end

  end

  describe Lauth::Determination::Allowed do
    let(:determination) { Lauth::Determination::Allowed.new }
    include_examples "a determination", "allowed"
  end

  describe Lauth::Determination::Denied do
    let(:determination) { Lauth::Determination::Denied.new }
    include_examples "a determination", "denied"
  end

end
