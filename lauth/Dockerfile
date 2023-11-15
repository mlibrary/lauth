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
    apt update && apt-get --no-install-recommends install -yq \
      build-essential \
      libmariadb-dev \
      curl \
      git \
      unzip

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE_VERSION} && \
    apt-get install nodejs -yq

RUN gem install bundler:${BUNDLER_VERSION}

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}

ENV PATH="/lauth/lauth/bin:$PATH"
WORKDIR /lauth/lauth
COPY package.json package-lock.json ./
RUN npm install

COPY ./lauth/Gemfile* .


#############
FROM base AS base-dev

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get --no-install-recommends install -yq \
      fd-find \
      less \
      ripgrep \
      vim-tiny

RUN gem install foreman


############
FROM base AS gems-prod

RUN --mount=type=cache,id=lauth-bundle-prod,sharing=locked,target=/vendor/bundle \
    --mount=type=cache,sharing=locked,target=/vendor/cache \
    bundle config set path /vendor/bundle && \
    bundle config set cache_path /vendor/cache && \
    bundle config set cache_all true && \
    bundle config set without 'development test' && \
    bundle cache --no-install && \
    bundle install --local && \
    bundle clean && \
    bundle config unset cache_path && \
    bundle config set path /gems && \
    mkdir -p /gems && \
    cp -ar /vendor/bundle/* /gems


#############
FROM base-dev AS gems-dev

RUN --mount=type=cache,id=lauth-bundle-dev,sharing=locked,target=/vendor/bundle \
    --mount=type=cache,sharing=locked,target=/vendor/cache \
    bundle config set path /vendor/bundle && \
    bundle config set cache_path /vendor/cache && \
    bundle config set cache_all true && \
    bundle cache --no-install && \
    bundle install --local && \
    bundle clean && \
    bundle config unset cache_path && \
    bundle config set path /gems && \
    mkdir -p /gems && \
    cp -ar /vendor/bundle/* /gems


#############
FROM gems-prod AS production

COPY ./lauth .
RUN chown -R ${UID}:${GID} /gems && chown -R ${UID}:${GID} /lauth/lauth

ENV HANAMI_ENV=production

EXPOSE 2300
USER $UNAME
CMD ["puma"]


############
FROM gems-dev AS development

COPY ./lauth .
RUN chown -R ${UID}:${GID} /gems && chown -R ${UID}:${GID} /lauth/lauth

EXPOSE 2300
USER $UNAME
CMD ["bin/dev"]
