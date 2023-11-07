ARG RUBY_VERSION=3.2.2
ARG RUBY_SLIM="-slim"
FROM ruby:${RUBY_VERSION}${RUBY_SLIM} AS base

ARG UNAME=lauth
ARG UID=1000
ARG GID=1000

ARG BUNDLER_VERSION=2.4.21
ARG NODE_VERSION=20

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt-get --no-install-recommends install -y \
      build-essential \
      libmariadb-dev \
      curl \
      git \
      unzip

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE_VERSION} && \
    apt-get install nodejs -y

RUN gem install foreman bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
# RUN chown -R ${UID}:${GID} /usr/local/bundle
# RUN mkdir -p /lauth/api /lauth/lib
# RUN mkdir -p /gems && chown ${UID}:${GID} /gems

WORKDIR /lauth/lauth
COPY ./lauth/Gemfile* .

ENV PATH="/lauth/lauth/bin:$PATH"

############
FROM base AS gems
RUN --mount=type=cache,sharing=locked,target=/gemcache \
    --mount=type=cache,sharing=locked,target=/gembuild \
    mkdir -p /gems && \
    unset BUNDLE_APP_CONFIG && \
    bundle config set app_config .bundle && \
    bundle config set path /gembuild && \
    bundle config set cache_path /gemcache && \
    bundle config set without 'development test' && \
    bundle cache && \
    bundle clean && \
    bundle config set path /gems && \
    bundle config unset cache_path && \
    cp -ar /gembuild/* /gems


#############
FROM gems AS dev-gems
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt-get --no-install-recommends install -yq \
      fd-find \
      less \
      ripgrep \
      vim-tiny

RUN --mount=type=cache,sharing=locked,target=/gemcache \
    --mount=type=cache,sharing=locked,target=/gembuild-dev \
    bundle config set path /gembuild-dev && \
    bundle config set cache_path /gemcache && \
    bundle config set without '' && \
    bundle cache && \
    bundle clean && \
    bundle config set path /gems && \
    bundle config unset cache_path && \
    cp -ar /gembuild-dev/* /gems


#############
FROM gems AS production

COPY ./lauth .
RUN chown -R ${UID}:${GID} /gems && chown -R ${UID}:${GID} /lauth/lauth
RUN bundle config set path /gems

ENV HANAMI_ENV=production

EXPOSE 2300
USER $UNAME
CMD ["bin/puma"]


############
FROM dev-gems AS development

COPY ./lauth .
RUN chown -R ${UID}:${GID} /gems && chown -R ${UID}:${GID} /lauth/lauth
RUN bundle config set path /gems

EXPOSE 2300
USER $UNAME
CMD ["hanami", "server"]
