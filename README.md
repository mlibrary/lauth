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

# api
Database Shell Window
``` shell
docker compose --file docker-compose-api.yml up --build
```
Specs Shell Window
``` shell
docker compose --file docker-compose-api.yml build api
docker compose --file docker-compose-api.yml run --rm api
docker compose --file docker-compose-api.yml down
```

# cli
Database Shell Window
``` shell
docker compose --file docker-compose-cli.yml up --build
```
API Shell Window
``` shell
docker compose --file docker-compose-cli.yml build api
docker compose --file docker-compose-cli.yml run --rm api
```
Specs Shell Window
``` shell
docker compose --file docker-compose-cil.yml build cli
docker compose --file docker-compose-cli.yml run --rm cli
docker compose --file docker-compose-cli.yml down
```
