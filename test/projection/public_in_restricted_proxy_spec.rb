RSpec.describe "Projecting public access in restricted, proxied space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space and proxied to an
  # external app, but adopts the rules for a public collection.
  #
  # See public_in_restricted_spec.rb but without the proxy setup
end
