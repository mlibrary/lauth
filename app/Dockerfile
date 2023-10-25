ARG RUBY_VERSION=3.2
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.3
ARG UNAME=lauth
ARG UID=1000
ARG GID=1000

LABEL maintainer="dla-staff@umich.edu"

# Install Vim (optional)
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim-tiny

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /lauth/app /lauth/lib
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

ENV BUNDLE_PATH /gems

WORKDIR /lauth/app
COPY --chown=${UID}:${GID} app/Gemfile* /lauth/app

USER $UNAME

RUN bundle _${BUNDLER_VERSION}_ install

COPY app/ /lauth/app
COPY lib/ /lauth/lib

EXPOSE 2300
CMD ["bin/rackup", "-o", "0.0.0.0", "-p", "2300"]
