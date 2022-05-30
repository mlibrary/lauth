RSpec.describe "Projecting public access in restricted space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space, but adopts the rules for
  # a public collection.
end
