RSpec.describe "Projecting restricted access in public, proxied space" do
  # These are resources that are rewritten internally and sent back through the
  # rewrite rules to be authorized as another collection. Specifically, the
  # request URL would normally be in public, proxied space, but adopts the
  # rules for a restricted collection.

  # create a collection pub_coll, with a location, public
  # create a collection foo, with a location
  # setup a proxy for pub_coll
  # add a rewrite rule to apache config that rewrites locations /pub_coll/ to /foo/
  # create a user foo_user
  # create a grant foo_user -> foo
  #
  # Unclear if we actually need the proxied app, but we have one so could use it.
  #
  # as nobody, request pub_coll -> rewrites to foo, denied
  # as nobody, request foo -> is foo, denied (maybe skip this case)
  # as foo_user, request pub_coll -> rewrites to foo, allowed
  # as foo_user, request foo -> is foo, allowed
end
