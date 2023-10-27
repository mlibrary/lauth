# Stub website/applications for testing

This is a test site for Apache to serve. There are some static files that
represent resources that should have various restrictions. They are configured
in `test-site.conf`, loaded directly from httpd.conf (per the Dockerfile). The
`web` directory serves as the document root.

The entire module directory is mounted at `/lauth/module`, and this directory
is mounted at `/lauth/test-site`.

There is an htpasswd file used for HTTP Basic authentication. There are two
users included here:

- `lauth-allowed`, with password `allowed` -- representing a user who can
  authenticate, and will have various memberships and grants, so should be
  allowed access to restricted items
- `lauth-denied`, with password `denied` -- representing a user who can
  authenticate, but has no memberships or grants, so should be denied access
  to any restricted items

This arrangement is to simulate a single sign-on scenario where `REMOTE_USER`
would be set via session cookie. This is sufficient to give 401 responses
before the module processes the request. This may be replaced by a stub SSO
module/app if we ultimately do need to treat the redirects to login as
different than the basic prompt for authentication.

## Filenames / meanings

The directories under `web/` represent content under different scenarios and
configurations. There are only index.html files in each directory so that the
URLs can be the directory name, indicating simple, clear test scenarios.

- **web/** -- allowed by implicit public designation (unregistered URL)
  - **exemption/** -- denied for any requester (no grants, no exemption)
    - **global/** -- allowed by subpath authentication exemption in global configuration
    - **vhost/** -- allowed by subpath authentication exemption in virtual host configuration
  - **network/** -- allowed by authorized network
  - **public/** -- allowed by explicit public designation
  - **user/** -- allowed by user authentication
  - **user-or-network/** -- allowed by user authentication or authorized network
