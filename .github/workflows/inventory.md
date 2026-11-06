# Workflow Inventory

We have a bunch of workflow definitions pieced together over time and it's
time to clean them up. This is the starting point of mapping out our needs
which workflows should be retained, combined, eliminate, or updated.

 | name                 | triggers on                                    |
 |----------------------|----------------------------------------------- |
 | branch-scratch       | dispatch                                       |
 | build-apache-latest  | dispatch, push main                            |
 | build-db-latest      | dispatch, push main                            |
 | build-lauth-latest   | dispatch, push main                            |
 | build-production     | workflow_call                                  |
 | build-sync-latest    | dispatch                                       |
 | ci                   | dispatch, main PR merged                       |
 | delete-workflow-runs | dispatch                                       |
 | deploy-staging       | release                                        |
 | release-cli          | tag (v*)                                       |

### branch-scratch

A placeholder workflow to modify in a branch and be able to trigger it from the
web UI. This is a quirk of GHA that workflows can be run as they are _on_ a branch
but they need to be in main to appear in the UI at all.

### build-apache-latest

Builds the whole module, packages, and server image. Pushes one container image
for the server as `lauth/lauth-apache`, and build artifact with all of the debs
included in a zip.

### build-db-latest

Builds and pushes `lauth/db-builder` for initializing the database from a
container image.

### build-lauth-latest

Builds the API application and pushes the image as `lauth/lauth`. Pushes as
latest tag and the commit sha.

### build-production

Customized version of `mlibrary/platform-engineering-workflows/build-production`.
Its purpose is to allow passing the target of a multi-stage build. It is only
used from deploy-staging.

### build-sync-latest

Builds the db-sync image (spark scala + script) and pushes as `lauth/db-sync`.

### ci

Builds and runs tests for everything (API, client tests, system tests, cli).
Does not push anything.

### delete-workflow-runs

Deletes workflow runs older than a specified number of days; not scheduled.

### deploy-staging

Builds staging image, delegating to `build-production` based on a git tag.
Pushes the container image and updates the `web-image.txt` file for staging in
the config repository (by way of repository event). Triggers on GitHub release
of a git tag.

### release-cli

Builds and pushes golang package for the CLI, based on git tag.
