# Apache module for compatibility

This module is the replacement for `mod_authz_umichlib`. It is set up to
build with C++20 and uses two header-only libraries for dealing with the
HTTPS and JSON details conveniently.

As it stands, this is only a stub module, paving the way for development.
The module registers a handler for `/lauth`, which renders some static JSON
and makes a request to the API via the `api.lauth.local` host defined in
the Compose file.

## Building

The Makefile handles building the module and the Dockerfile installs the
module into the Apache server. This means that building the image is made
straightforward from the top level directory:

```
docker compose build apache
```

## Running

Once built, the server can be run under Compose, and it will map port 8888
from your host system:

```
docker compose up apache
```

You can also do the build/rebuild and startup in one step for making
incremental changes to the module or config. Changes to the client or the
module should be detected and rebuilt as necessary.

```
docker compose up apache --build
```

## Unit Tests

This package is divided into two pieces: an API client and the thin module to
handle the Apache request portions. The API client has unit tests using
GoogleTest, run with Bazel, in the `client/` directory.

The Bazel WORKSPACE and BUILD files set up the artifacts and dependencies.
Running the tests is straightforward within a container, with either make or
bazel directly. To run tests repeatedly without the setup steps, the easiest
way is to use an interactive shell in the `apache` Compose service: 

```
docker run --rm apache bash
make test

cd client
bazel test --test_output=all ...
```

Note that the `--test_output` argument is optional and `...` is shorthand for
all packages in the workspace. This could also be run as `//...` or with a
a specific package, like `//test:client_test`.

## Test site virtual host / DNS entries

The test site is configured with a ServerName of `www.lauth.local`. When
running under Compose, this is also the container's hostname, so requests will
be served over http through the default port forwarding at localhost:8888. To
test HTTPS or other virtual hosts, you would need to add local hosts entries to
alias those names to localhost or run from within another container on the same
(default) network under Compose.
