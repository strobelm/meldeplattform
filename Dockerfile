FROM golang:1.19-alpine3.17 AS dependencies

ENV GOPATH="/go"

RUN mkdir -p "$GOPATH/src" "$GOPATH/pkg"

WORKDIR /src
COPY go.mod go.sum ./

RUN go mod download

FROM golang:1.19-alpine3.17 AS builder

ENV GOPATH="/go"

COPY --from=dependencies $GOPATH/pkg $GOPATH/pkg
COPY --from=dependencies $GOPATH/src $GOPATH/src

WORKDIR /src

COPY . .

RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /app cmd/meldung/meldung.go

FROM alpine:3.17

RUN apk add --no-cache ca-certificates curl

WORKDIR /

COPY --from=builder /app /app
COPY config /config

EXPOSE 8080
HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

CMD ["/app"]
