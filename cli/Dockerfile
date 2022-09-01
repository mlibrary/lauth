ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.3
ARG UNAME=lauth
ARG UID=1000
ARG GID=1000

LABEL maintainer="dla-staff@umich.edu"

# Install Vim (optional)
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  default-mysql-client \
  vim-tiny

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /lauth/cli /lauth/lib
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

ENV BUNDLE_PATH /gems

WORKDIR /lauth/cli
COPY cli/Gemfile* /lauth/cli
RUN chown ${UID}:${GID} /lauth/cli/Gemfile*

USER $UNAME

RUN bundle install

COPY cli/ /lauth/cli
COPY lib/ /lauth/lib

CMD ["sleep", "infinity"]
