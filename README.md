# lauth - Library Authorization

**lauth** is an umbrella/monorepo for Library Authorization projects. This is
implementation of a new/ported authorization system to migrate/replace the
legacy system running for many years. The new design is API-oriented rather
than database-oriented.

The modules are:

 - **[api/](./api/)** - REST API for authentication/authorization
 - **[cli/](./cli/)** - Command-line client for data management
 - **[module/](./module/)** - Apache module for compatibility
 - **[test/](./test/)** - End-to-end acceptance tests

These modules may be broken out to individual repositories at some time, but
they are colocated for convenience and shared evolution for now.

# Docker Compose Test Suites
## docker-compose-api.yml
### Service Shell
``` shell
docker compose --file docker-compose-api.yml up --build
ctrl-c
docker compose --file docker-compose-api.yml down
```
### Test Shell
``` shell
docker compose --file docker-compose-api.yml build api
docker compose --file docker-compose-api.yml run --rm api
```
## docker-compose-cli.yml
### Service Shell
``` shell
docker compose --file docker-compose-cli.yml up --build
ctrl-c
docker compose --file docker-compose-cli.yml down
```
### Test Shell
``` shell
docker compose --file docker-compose-cli.yml build cli
docker compose --file docker-compose-cli.yml run --rm cli
```