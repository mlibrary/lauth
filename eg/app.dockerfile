ARG RUBY_VERSION=3.2.2
FROM ruby:${RUBY_VERSION}

ARG BUNDLER_VERSION=2.4.10
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

RUN mkdir -p /lauth/gems && chown ${UID}:${GID} /lauth/gems
ENV BUNDLE_PATH /lauth/gems

COPY --chown=${UID}:${GID} . /lauth/app

WORKDIR /lauth/app
USER $UNAME
RUN bundle _${BUNDLER_VERSION}_ install

EXPOSE 2300
CMD ["bin/hanami", "server", "--host=0.0.0.0", "--port=2300"]
