RSpec.describe "Enforced authentication" do
  # This relates to CosignProtected On CosignAllowPublicAccess Off.
  #
  # It is a rather strange scenario connected to a legacy policy that HTTPS
  # indicated the need to log in. Because of this, there might be resources
  # that are intended to be accessible by IP range, but configured with
  # enforced authentication; a public guest user would be able to access the
  # resources via HTTP, but not via HTTPS because they could not log in.
  #
  # That scenario is likely obsolete and could be considered a configuration bug.

  # Assume testing with off-campus IP and login-or-IP-restricted resource is sufficient

  # When enforced and on HTTP, redirect to HTTPS
  # When enforced and on HTTPS and not logged in (no REMOTE_USER), redirect to login
  # When enforced and on HTTPS and logged in, proceed/allow

  # Dubious current behavior:
  # login-or-IP-restricted resource, matching client via HTTP, allow
  # login-or-IP-restricted resource, matching client via HTTPS, force login
end
