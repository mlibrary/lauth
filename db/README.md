# Auth database setup

There are raw SQL files here to set up the legacy schema in MariaDB/MySQL:

- [tables.sql](tables.sql) - Create the tables, indexes, and field constraints
- [root.sql](root.sql) - Set up a root user so keys can be enforced
- [keys.sql](keys.sql) - Create foreign keys
- [test-fixture.sql](test-fixture.sql) - Load test site data
- [drop-keys.sql](drop-keys.sql) - Drop foreign keys; to allow for truncate/reload
- [sync/sync.sc](sync/sync.sc) - A Spark script to migrate data from Oracle to MariaDB

## Local setup with Docker Compose

If running with the Docker Compose setup at the root directory, these files will
be mounted at `/sql`. You can load them the `mariadb` cli in the image.

### Quickstart

There is a `dbsetup` service defined that will start the database in the
background if needed, load the `.sql` files, and leave the database running.

```
docker compose up dbsetup
```

### Manual Initialization

The database can be started and initialized step by step if you want more
control:

```
docker compose up -d mariadb
docker compose exec mariadb bash

# Within the container

cd /sql
mariadb -u root lauth < tables.sql
mariadb -u root lauth < root.sql
mariadb -u root lauth < keys.sql
mariadb -u root lauth < test-fixture.sql
```

### Resetting the database

By default, the database will persist to a volume, so you can use `docker
compose stop` to shut it down, and restart with `docker compose up`. If you
want to clear the volume and start over completely, you can use `docker compose
down mariadb`.
