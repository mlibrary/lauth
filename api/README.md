# lauth-api - Library Authorization API

A REST API to provide the functionality of the legacy auth database over HTTPS,
rather than a direct connection and SQL queries from the clients.

Tools used for implementation

 - [Hanami::API](https://github.com/hanami/api) - Mini-framework handling HTTP,
   routing, and seriazliation.
 - [ROM](https://rom-rb.org/) - Ruby Object Mapper; used to build repositories,
   entities, and SQL mapping.

## NOTE: Stub status!

As it stands, this is a minimal stub, intended to plumb together the pieces.
It's not really an API yet and everything is inlined. The individual endpoints
(for different resources / actions) will likely be separated out and hooked
into the Lauth::API (e.g., `get "/users", to: UsersEndpoint.new`). The data
mapping and interactors will likely move out to `lib`.

The stub API responds to two URL routes:

 - **GET /** - A static message with the version
 - **GET /users/:id** - A JSON-rendered `aa_user` row for the supplied userid

## Directory Layout

The directory structure is set up to make space for code unrelated to serving
the API to be extracted and shared. The lib directory at the top level is that
space. This mostly follows the Hanami / "Clean Architecture" convention.

The Compose file uses the top level as the build context for the container,
copying this directory in as `/lauth/api` and the sibling `lib` directory as
`/lauth/lib`.

## Running the API

The API can be run under Docker Compose. There is a gem cache, so the bundle
will not need to be built on each app change. For now, there is no code
reloading.

You can build the image from the top level directory with:

```
docker compose build api
```

You can run it (optionally with the `-d` flag to put it in the background with:

```
docker compose up api
```

The api service will forward port 9292, meaning you should be able to load
http://localhost:9292 in a browser.

### Running locally (not in a container)

You could also run the API locally, with a Ruby 3.1 environment and by setting
the database URL, as in the next section. The API is a Rack app, and there is
a rackup file, `config.ru`. There is also a binstub, so you can start it up
with:

```
bin/rackup
```

## Connecting to the database

By default, the API connects to the database in the `mariadb` service, with
the default credentials. If you need to change this, you can set a connection
string in the `DATABASE_URL` environment variable.
