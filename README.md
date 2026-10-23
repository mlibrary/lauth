# lauth - Library Authorization

**lauth** is an umbrella/monorepo for Library Authorization projects. This is
implementation of a new/ported authorization system to migrate/replace the
legacy system running for many years. The new design is API-oriented rather
than database-oriented.

The modules are:

  - **[apache/](./apache/)** - Apache module for compatibility
  - **[lauth/](./lauth/)** - REST API for authentication/authorization
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

Run focused Ruby unit or request specs in the application container:

```sh
docker compose run --rm app-dev rspec <spec paths>
```

## Building and Testing the CLI

The Go administrative CLI lives under `cli/` and uses the versioned
administrative API. Its tests and release configuration checks can run in the
Compose development container from the repository root:

```sh
docker compose run --rm cli-dev
```

The default `cli-dev` command runs `go test ./...`, `go vet ./...`, and
`goreleaser check`. To run a focused test directly:

```sh
docker compose run --rm cli-dev go test ./internal/cli
```

To run the CLI from the development container:

```sh
docker compose run --rm cli-dev go run ./cmd/lauth --help
```

For host-side development, the equivalent commands can be run from `cli/`:

```sh
go test ./...
go vet ./...
goreleaser check
```

The CLI configuration uses `AUTHZ_API_BASE_URL`, `AUTHZ_API_TOKEN`, and the
optional `AUTHZ_API_TIMEOUT` environment variables. Run `go run ./cmd/lauth
--help` from `cli/` to inspect the command suite.

## Resetting Local Services

To stop the Compose services and remove their containers:

```
docker compose down --remove-orphans
```

This preserves the database volume. To also delete the local database data and
start from a fresh database, use the destructive form:

```
docker compose down --volumes --remove-orphans
```

Only use the volume-removal form when you intend to discard local database
state.
