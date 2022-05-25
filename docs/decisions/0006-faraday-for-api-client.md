---
status: accepted
date: 2022-05-25
---
# Use Faraday as the HTTP/REST API client

## Context and Problem Statement

There are many Ruby libraries to make HTTP requests and parse JSON, that is, to
make typical REST API calls. Some of these libraries are more raw, more
configurable, more expressive, or more focused on REST than others.

We should choose a library that makes it easy for us to assemble an API client
that can be used without coupling to that implementation. Noting that the API
itself will be minimal (as in [0003-rest-api](0003-rest-api.md)),
auto-discovery, parameter validation, and built-in marshaling are not
priorities.

## Considered Options

* net-http and json (stdlib)
* rest-client
* faraday
* swagger-codegen

## Decision Outcome

Chosen option: Faraday

We have selected Faraday because it is familiar and provides a middle level of
abstraction that should be effective for us. Working directly with Net::HTTP
has proven challenging and quirky enough that there are multiple different
libraries that wrap it toward a more approachable and consistent API. Working
with swagger-codegen places emphasis on automated tooling and client libraries
to be used by large teams or the public. Faraday sits in between, giving an API
that is still rather low level, but offering better consistency and additional
functionality through a middleware or plugin model.

RestClient offers a similar API and level of abstraction, albeit without the
middleware design. It would certainly suffice for our needs. We selected
Faraday primarily in this case because it is known, proven quantity in our
other applications.

In any case, we will use a clear boundary beyond which the choice is
immaterial, providing structured API requests and responses without the Faraday
details leaking through. If Faraday causes issues therein, we would likely
pursue RestClient or similar as an alternative.
