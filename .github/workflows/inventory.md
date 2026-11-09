# Workflow Inventory

We have a bunch of workflow definitions pieced together over time and it's
time to clean them up. This is the starting point of mapping out our needs
which workflows should be retained, combined, eliminate, or updated.

 | name                 | triggers on                                    |
 |----------------------|----------------------------------------------- |
 | branch-scratch       | dispatch                                       |
 | build-apache-latest  | dispatch, push main, workflow_call             |
 | build-db-latest      | dispatch, push main                            |
 | build-lauth-latest   | dispatch, push main                            |
 | build-production     | workflow_call                                  |
 | build-sync-latest    | dispatch                                       |
 | ci                   | dispatch, main PR merged                       |
 | delete-workflow-runs | dispatch                                       |
 | deploy-staging       | workflow_call                                  |
 | release-cli          | tag (v*)                                       |

### branch-scratch

A placeholder workflow to modify in a branch and be able to trigger it from the
web UI. This is a quirk of GHA that workflows can be run as they are _on_ a branch
but they need to be in main to appear in the UI at all.

### build-apache-latest

Builds and pushes the Apache server image, and uploads the `.deb` packages as a
workflow artifact. `release-cli` also calls this workflow and attaches those
packages to the GitHub Release.

### build-db-latest

Builds and pushes `lauth/db-builder` for initializing the database from a
container image.

### build-lauth-latest

Builds the API application and pushes the image as `lauth/lauth`. Pushes as
latest tag and the commit sha.

### build-production

Customized version of `mlibrary/platform-engineering-workflows/build-production`.
It allows passing the target of a multi-stage build and is called by
`release-cli` to build and push the production image before publishing the
GitHub Release.

### build-sync-latest

Builds the db-sync image (spark scala + script) and pushes as `lauth/db-sync`.

### ci

Builds and runs tests for everything (API, client tests, system tests, cli).
Does not push anything.

### delete-workflow-runs

Deletes workflow runs older than a specified number of days; not scheduled.

### deploy-staging

Deploys the already-built production image and updates the `web-image.txt` file
for staging in the config repository. Called by `release-cli` after the image
build and GitHub Release succeed.

### release-cli

Builds and pushes the production and Apache images, publishes the GoReleaser
CLI artifacts and Apache `.deb` packages to the GitHub Release, then deploys
staging for a pushed `v*` tag.
