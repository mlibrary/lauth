RSpec.describe "Projecting restricted access in public space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in public space, but adopts the rules for
  # a restricted collection.

  # See restricted_in_public_proxy_spec.rb but without the proxy setup
end
