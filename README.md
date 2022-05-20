# lauth - Library Authorization

**lauth** is an umbrella/monorepo for Library Authorization projects. This is
implementation of a new/ported authorization system to migrate/replace the
legacy system running for many years. The new design is API-oriented rather
than database-oriented.

The modules are:

 - **[api/](./api/)** - REST API for authentication/authorization
 - **[cli/](./cli/)** - Command-line client for data management

These modules may be broken out to individual repositories at some time, but
they are colocated for convenience and shared evolution for now.
