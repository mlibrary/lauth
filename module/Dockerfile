FROM httpd:2.4-bullseye

RUN apt update; \
    apt install -y --no-install-recommends \
        apache2-dev \
        ca-certificates \
        g++ \
        libssl-dev \
        curl

RUN MACHINE=`gcc -dumpmachine`; if echo $MACHINE | grep -q aarch64; then CPU_ARCH=arm64; else CPU_ARCH=amd64; fi; \
    curl -fsSL -o /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.12.0/bazelisk-linux-${CPU_ARCH} \
    && chmod +x /usr/local/bin/bazel \
    && mkdir -p /tmp/bazel-setup \
    && cd /tmp/bazel-setup \
    && bazel

WORKDIR /module
COPY . /module

RUN make install clean
COPY conf/lauth.conf conf/test-site.conf /usr/local/apache2/conf
RUN echo "Define cpu_arch \"`gcc -dumpmachine`\"\nInclude conf/lauth.conf\nInclude conf/test-site.conf" >> /usr/local/apache2/conf/httpd.conf
