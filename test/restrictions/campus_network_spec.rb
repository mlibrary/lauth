RSpec.describe "Access to resources restricted to a known network" do
  # These resources should require that the client IP address is within an
  # authorized range (implying use of an authorized institution's computing
  # resources).
  #
  # We should test inside and outside of a contiguous range and within a denied
  # subnet inside a larger network.
end
