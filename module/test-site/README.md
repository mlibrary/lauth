# Stub website/applications for testing

This is a test site for Apache to serve. There are some static files that
represent resources that should have various restrictions. They are configured
in `test-site.conf`, loaded directly from httpd.conf (per the Dockerfile). The
`web` directory serves as the document root.

The entire module directory is mounted at `/module`, so this directory becomes
`/module/test-site`.

There is an htpasswd file used for HTTP Basic authentication. The only user is
`lauth`, with the password `lauth`. This is to simulate a single sign-on
scenario where `REMOTE_USER` would be set via session cookie. This is
sufficient to give 401 responses before the module processes the request. This
may be replaced by a stub SSO module/app if we ultimately do need to treat the
redirects to login as different than the basic prompt for authentication.

## Filenames / meanings

These directory and filenames are imported from a previous characterization
test suite. They do not need to remain the same, but are here for reference.

The meanings are:

 - `public` - unrestricted access
 - `lit-authn` - restricted to authenticated users (in practice, U-M users,
   authenticated via Cosign)
 - `lit-ip` - restricted to clients on an authorized network (e.g., campus users)
 - `lit-authn-or-ip` - restricted to authenticated or network users
 - `exempted_toplevel` - unrestricted access under what would be a restricted
    URL space because of an exemption at the server/module configuration
 - `exempted_toplevel` - unrestricted access under what would be a restricted
    URL space because of an exemption at the site/virtual host configuration
