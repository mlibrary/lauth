FROM debian:bullseye-slim AS build-base
RUN apt update; \
    apt install -y --no-install-recommends \
        apache2-dev \
        ca-certificates \
        g++ \
        libssl-dev \
        curl \
        git \
        meson \
        ninja-build
RUN mkdir -p /lauth/apache

###
FROM build-base AS module

COPY ./apache/client /lauth/apache/client/
RUN meson setup /lauth/apache/build /lauth/apache/client

WORKDIR /lauth/apache/build
RUN meson install

COPY ./apache/remoteuser /lauth/apache/remoteuser/
WORKDIR /lauth/apache/remoteuser
RUN make install

COPY ./apache/module /lauth/apache/module/
WORKDIR /lauth/apache/module
RUN make install

###
FROM build-base AS client-tests
COPY ./apache/client /lauth/apache/client/
RUN meson setup /lauth/apache/client/build /lauth/apache/client
WORKDIR /lauth/apache/client/build
RUN meson configure -Dtests=true -Dintegration-tests=true && meson compile
CMD ["meson", "test", "-v"]

###
FROM module AS tests
WORKDIR /lauth/apache/build
RUN meson configure -Dtests=true -Dintegration-tests=true && meson compile
CMD ["meson", "test", "-v"]

###
FROM build-base AS packages

COPY ./apache/debpkgs /lauth/apache/debpkgs
WORKDIR /lauth/apache/debpkgs

# http-check
COPY --from=module /lauth/apache/build/http-check /lauth/apache/debpkgs/http-check/usr/bin/
RUN ./package http-check

# mod-authn-remoteuser
COPY --from=module /usr/lib/apache2/modules/mod_authn_remoteuser.so /lauth/apache/debpkgs/mod-authn-remoteuser/usr/lib/apache2/modules/
RUN ./package mod-authn-remoteuser

# mod-lauth
COPY --from=module /usr/local/ /lauth/apache/debpkgs/mod-lauth/usr/
COPY --from=module /usr/lib/apache2/modules/mod_lauth.so /lauth/apache/debpkgs/mod-lauth/usr/lib/apache2/modules/
RUN ./package mod-lauth

# Docker Compose Volume Mapping Directory
COPY ./apache/packages /lauth/apache/packages

##
FROM debian:bullseye-slim AS server
RUN apt update; \
    apt install -y --no-install-recommends \
        ca-certificates \
        apache2

# enable available apache2 modules
RUN a2enmod authz_groupfile cgid headers proxy proxy_http remoteip rewrite

# install debian packages: http-check, mod-authn-remoteuser, mod-lauth
COPY --from=packages /lauth/apache/debpkgs/*.deb /tmp
RUN dpkg -i /tmp/*.deb
RUN rm -f /tmp/*.deb

# enable apache2 modules: lauth
RUN a2enmod lauth

CMD ["apache2ctl", "-D", "FOREGROUND"]

##
FROM server AS test-server

# enable apache2 modules: authn-remoteuser
RUN a2enmod authn_remoteuser

COPY ./test-site /lauth/test-site
COPY ./apache/conf/test-site.conf /etc/apache2/sites-available/test-site.conf
RUN a2ensite test-site
RUN a2dissite 000-default

RUN cp /lauth/test-site/cgi/printenv /usr/lib/cgi-bin/
