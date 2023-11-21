RSpec.describe Lauth::Access::Result do
  let(:determination_value) { "denied" } # TODO: enum
  it do
    result = Lauth::Access::Result.new(determination: determination_value)
    expect(result.determination).to eq(determination_value)
  end
end
