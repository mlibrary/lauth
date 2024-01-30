RSpec.describe "Projecting public access in restricted space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in restricted space, but adopts the rules for
  # a public collection.

  # create a collection pubc, with location, public
  # create a collection priv, with location
  # add rewrite rule in apache conf /priv/ -> /pub/
  # create a user priv_user
  # add grant priv_user -> priv (technically we shouldn't need this, but....)
  #
  # as nobody, request pubc -> is pubc, allowed
  # as nobody, request priv -> rewrites to pubc, allowed
  # as priv_user, request pubc -> is pubc, allowed
  # as priv_user, request priv -> rewrites to pubc, allowed
end
