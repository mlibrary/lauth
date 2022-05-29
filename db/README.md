# Auth database setup

There are raw SQL files here to setup the legacy schema in MariaDB/MySQL:

- [tables.sql](tables.sql) - Create the tables, indexes, and field constraints
- [root.sql](root.sql) - Set up a root user so keys can be enforced
- [keys.sql](keys.sql) - Create foreign keys
- [drop-keys.sql](drop-keys.sql) - Drop foreign keys; to allow for truncate/reload
- [migrate.sc](migrate.sc) - A Spark script to migrate data from Oracle to MariaDB

## Local setup with Docker Compose

If running with the Docker Compose setup at the root directory, these files will
be mounted at `/sql`. You can load them the `mysql` cli in the image. For example:

```
docker compose up -d mariadb
docker compose exec mariadb bash

# Within the container

cd /sql
mysql -u root lauth < tables.sql
mysql -u root lauth < root.sql
mysql -u root lauth < keys.sql
```

By default, the database will persist to a volume, so you can use `docker
compose stop` to shut it down, and restart with `docker compose up`. If you
want to clear the volume and start over completely, you can use `docker compose
down mariadb`.
