# System / Acceptance Tests

These are acceptance tests. For now, this is an RSpec-only project, so the
default path is at this level, rather than an extra spec directory.  Files
matching `*_spec.rb` will run. There is an rspec binstub along with an `.envrc`
file for direnv, so you can run `rspec` from any directory. Running in a
subdirectory will require specifying either `.` or something more specific,
like a file, file pattern, or directory.

We may choose to convert these to Cucumber or leave them in RSpec.

The tests are arranged according to features of the auth system. There are many
variables that affect the behavior, and we seek to cover the features without
taking the cross product of all variables. However, those variables and their
ranges are:

 - Restriction: U-M login, campus network, login or network, public (none)
 - Identity: anonymous, U-M member (via weblogin)
 - User Location: on-campus, off-campus
 - Protocol: HTTP, HTTPS
 - Authentication Mode:
   - enforced - user is required to log in, regardless of location
   - passive - existing user login/identity will be considered, if present
 - Authorization Type (for collection):
   - normal - authorization is enforced by the web server
   - delegated - authorization is not enforced; app receives known information
 - Resource Type: static, dynamic, proxied
 - Exemption (restricted resource, but exempted):
   - server - the directory or location is configured as exempt server-wide
   - site - the directory or location is configured as exempt within a site
 - Projection (apply the rules for another resource via rewrite):
   - public resource projected in a restricted URL space
   - restricted resource projected in a public URL space
   - other restricted resource projected in a restricted URL space
   - restricted resource projected in a public, proxied URL space
   - public resource projected in a restricted, proxied URL space

## Running the Tests

The Compose file is set up to allow the tests to be run in a container. There
is a `test` service defined under the `test` profile, so it will not start by
default on `docker compose up` commands. However, you will need the `db`,
`api`, and `apache` services started. You will also need to be sure to install
the gems. Then you can target the service without specifying a profile.

You may want to run the database in the background and the API and Apache in
the foreground of separate terminal. For example:

```
docker compose up -d mariadb
docker compose up
```

Once all of the services are up, you can install the bundle and run the suite:

```
docker compose run test bundle
docker compose run test
```

You can also run specific tests with `bin/rspec` or other commands within the
test container, including opening an interactive shell.

Note that the local files are mounted in the container, so any changes made
to the `/test` directory will be reflected on your host system (like the
.example.status file for tracking success/failures).

It may be convenient to use a file watcher to rerun the suite on changes. For
example, you can use [fd](https://github.com/sharkdp/fd) and
[entr](https://eradman.com/entrproject/) as follows:

```
fd | entr -c docker compose run test
```
