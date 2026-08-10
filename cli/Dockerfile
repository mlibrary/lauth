FROM golang:1.25

RUN go install github.com/goreleaser/goreleaser/v2@v2.13.3

WORKDIR /lauth/cli

COPY ./cli/go.mod ./cli/go.sum ./
RUN go mod download

COPY ./cli/ ./

CMD ["sh", "-c", "go test ./... && go vet ./... && goreleaser check"]
