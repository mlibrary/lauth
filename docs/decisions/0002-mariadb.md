---
status: accepted
date: 2022-05-24
---
# Use MariaDB as the database

## Context and Problem Statement

The legacy auth system includes an Oracle database that is central to all
operation, holding information about institutions, collections, networks, and
users. We need to migrate this data and there are administrative functions that
need to update it. Continuing with a relational database is practical, though
we want to use something familiar and handy for containerized deployment.

The question is: which database should we use?

## Decision Drivers

* Existing infrastructure and administrative familiarity
* Support for a relatively direct translation of schema
* Availability of convenient and reliable container images

## Considered Options

* MariaDB
* PostgreSQL
* CockroachDB

## Decision Outcome

Chosen option: MariaDB

Given our existing investment in MariaDB throughout the enterprise, it is far
and away the most familiar option. All of the datatypes and referential
integrity features used in the legacy database are supported. There are
reliable container images and Helm charts, in addition to the typical packages,
drivers, and dialect support that are well established. These combine to make
it the best overall choice at present.


## More Information
  
PostgreSQL is attractive because of the amplifying support in the industry, and
because we may want to take advantage of some of its features (especially JSONB
columns), but there is a practical familiarity gap. CockroachDB is attractive
because of its distributed design as compared to our multi-region replication
demands, but we decided that we should experiment with it separately before
committing.

