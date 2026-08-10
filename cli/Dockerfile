ARG GO_VERSION=1.25
ARG GORELEASER_VERSION=2.13.3
FROM golang:${GO_VERSION} AS base

ARG UNAME=lauth
ARG UID=1000
ARG GID=1000


RUN groupadd -g ${GID} -o ${UNAME} && \
    useradd -m -d /lauth -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME} && \
    mkdir -p /go/pkg/mod /go/build-cache /go/bin /lauth/cli && \
    chmod 1777 /go/pkg/mod /go/build-cache && \
    chown -R ${UID}:${GID} /go /lauth

ENV PATH="/go/bin:${PATH}"
ENV GOMODCACHE="/go/pkg/mod"
ENV GOCACHE="/go/build-cache"
WORKDIR /lauth/cli

#############
FROM base AS development

RUN --mount=type=cache,id=lauth-cli-go-packages,sharing=locked,target=/go/pkg/mod \
    --mount=type=cache,id=lauth-cli-go-build,sharing=locked,target=/root/.cache/go-build \
    GOCACHE=/root/.cache/go-build go install github.com/goreleaser/goreleaser/v2@v${GORELEASER_VERSION}

COPY --chown=${UID}:${GID} ./cli/go.mod ./cli/go.sum ./
RUN --mount=type=cache,id=lauth-cli-go-packages,sharing=locked,target=/go/pkg/mod \
    go mod download

COPY --chown=${UID}:${GID} ./cli/ ./

USER ${UNAME}
CMD ["go", "run", "./cmd/lauth"]

#############
FROM base AS build

ENV CGO_ENABLED=0

COPY --chown=${UID}:${GID} ./cli/go.mod ./cli/go.sum ./
RUN --mount=type=cache,id=lauth-cli-go-packages,sharing=locked,target=/go/pkg/mod \
    go mod download

COPY --chown=${UID}:${GID} ./cli/ ./
RUN --mount=type=cache,id=lauth-cli-go-packages,sharing=locked,target=/go/pkg/mod \
    --mount=type=cache,id=lauth-cli-go-build,sharing=locked,target=/root/.cache/go-build \
    go build -o /lauth/bin/lauth ./cmd/lauth

#############
FROM gcr.io/distroless/static-debian12:nonroot AS distribution

COPY --from=build /lauth/bin/lauth /lauth

ENTRYPOINT ["/lauth"]
