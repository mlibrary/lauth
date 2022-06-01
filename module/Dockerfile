FROM httpd:2.4-bullseye

RUN apt update; \
    apt install -y --no-install-recommends \
        apache2-dev \
        ca-certificates \
        g++ \
        libssl-dev

WORKDIR /module
COPY . /module

RUN make install clean
COPY conf/lauth.conf conf/test-site.conf /usr/local/apache2/conf
RUN echo "Define cpu_arch \"`gcc -dumpmachine`\"\nInclude conf/lauth.conf\nInclude conf/test-site.conf" >> /usr/local/apache2/conf/httpd.conf
