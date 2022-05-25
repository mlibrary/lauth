---
status: accepted
date: 2022-05-24
---
# Use Behavior-Driven Development with Cucumber and Ruby

## Context and Problem Statement

The Library Authorization system has a long legacy as a hybrid application,
relying on an Apache module, Perl utilities, and an Oracle database. None of
these choices are bad, but the architecture is tightly coupled to the database.
In order to migrate toward a more loosely coupled design that is more
compatible with modern deployments in containers, behind different reverse
proxies (e.g., a Kubernetes Ingress), and with different authentication and
authorization needs, we want to reach shared understanding of the prevailing
requirements and integration scenarios.

To do so, we would like to use Behavior-Driven Development as a methodology.
There are various tools, and we could implement in any language.

## Decision Drivers

* Familiarity with language and libraries
* Availability of tutorial and reference material

## Considered Options

* Cucumber-Ruby and RSpec, implementation in Ruby
* Cucumber-Java and Spock, implementation in Java
* Acceptance testing in RSpec, implementation in Ruby

## Decision Outcome

Chosen option: Cucumber-Ruby and RSpec, implementation in Ruby

We selected the most familiar option for implementation, Ruby, because there
do not appear to be any requirements served especially well by some specific
library in another environment. Because we are familiar with Ruby and RSpec,
Cucumber-Ruby was a natural choice. We could have worked to use double-loop
TDD with RSpec alone, but decided that the Gherkin syntax and a separate runner
for the feature tests were valuable enough to work through some unfamiliarity.
