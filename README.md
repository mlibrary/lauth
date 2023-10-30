# lauth - Library Authorization

**lauth** is an umbrella/monorepo for Library Authorization projects. This is
implementation of a new/ported authorization system to migrate/replace the
legacy system running for many years. The new design is API-oriented rather
than database-oriented.

The modules are:

 - **[apache/](./apache/)** - Apache module for compatibility
 - **[api/](./api/)** - REST API for authentication/authorization
 - **[cli/](./cli/)** - Command-line client for data management
 - **[test/](./test/)** - End-to-end acceptance tests

These modules may be broken out to individual repositories at some time, but
they are colocated for convenience and shared evolution for now.

# Building and Running

Everything is set up to work with Docker Compose through the top-level
`docker-compose.yml` file. There are health checks and dependencies declared,
so using `up` or `run` should launch anything that a "service" needs.

## Starting Everything

You can bring up all of the services and ensure that all images are up to date
with two commands:

```
docker compose up dbsetup
docker compose up --build
```

You can run the `build` separately or apply the usual options to `up`, for
example, to run in the background (with `up -d` or `up --detach`).

## Running System Tests

```
docker compose run --rm test
```

## Resetting Everything

TODO: These need to be cleaned up/scripted

```
docker compose down --remove-orphans
docker rm -sfv
docker volume rm lauth_mariadb_data
```
