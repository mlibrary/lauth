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

COPY ./apache/module /lauth/apache/module/
WORKDIR /lauth/apache/module
RUN make install

###
FROM build-base AS client-tests
COPY ./apache/client /lauth/apache/client/
RUN meson setup /lauth/apache/client/build /lauth/apache/client
WORKDIR /lauth/apache/client/build
RUN meson configure -Dtests=true && meson compile
CMD ["meson", "test", "-v"]

###
FROM module AS tests
WORKDIR /lauth/apache/build
RUN meson configure -Dtests=true && meson compile
CMD ["meson", "test", "-v"]

###
FROM httpd:2.4-bullseye AS server
RUN mkdir -p /lauth

COPY --from=module /lauth/apache/build/http-check /usr/local/bin/
COPY --from=module /usr/local/ /usr/local/
RUN ldconfig

COPY --from=module /usr/lib/apache2/modules/mod_lauth.so /usr/local/apache2/modules/

COPY ./test-site /lauth/test-site/
COPY ./apache/conf/* /usr/local/apache2/conf/
