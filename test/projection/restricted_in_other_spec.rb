RSpec.describe "Projecting another collection in restricted space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space, but adopts the rules for
  # another restricted collection.

  # create a collection foo, with a location
  # create a collection bar, with a location
  # add rewrite rule to apache config that rewrites locations /foo/ to /bar/
  # create a user foo_user
  # create a grant for foo_user->foo
  # create a user bar_user
  # crete a grant for bar_user->bar
  #
  # as foo_user, request foo -> rewrites to bar, denied
  # as foo_user, request bar -> is bar, denied
  # as bar_user, request foo -> rewrites to bar, allowed
  # as bar_user, request foo -> is bar, allowed
end
