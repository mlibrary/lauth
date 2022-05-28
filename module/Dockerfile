FROM httpd:2.4-bullseye

RUN apt update; \
    apt install -y --no-install-recommends \
        apache2-dev

WORKDIR /module
COPY . /module
RUN make
