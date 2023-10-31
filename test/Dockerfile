ARG RUBY_VERSION=3.2.2
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.4.21
ARG UNAME=lauth
ARG UID=1001
ARG GID=1001

LABEL maintainer="dla-staff@umich.edu"

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /lauth/test && chown ${UID}:${GID} /lauth/test
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

ENV BUNDLE_PATH /gems
ENV PATH="/lauth/test/bin:${PATH}"

WORKDIR /lauth/test
COPY --chown=${UID}:${GID} test/Gemfile* /lauth/test

USER $UNAME

RUN bundle install

COPY --chown=${UID}:${GID} test/ /lauth/test

CMD ["rspec"]
