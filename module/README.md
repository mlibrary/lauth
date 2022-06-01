# Apache module for compatibility

This module is the replacement for `mod_authz_umichlib`. It is set up to
build with C++17 and uses two header-only libraries for dealing with the
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

## Test site virtual host / DNS entries

The test site is configured with a ServerName of `www.lauth.local`. When
running under Compose, this is also the container's hostname, so requests will
be served over http through the default port forwarding at localhost:8888. To
test HTTPS or other virtual hosts, you would need to add local hosts entries to
alias those names to localhost or run from within another container on the same
(default) network under Compose.
