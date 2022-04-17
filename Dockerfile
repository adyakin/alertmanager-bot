FROM golang:1.18-alpine AS builder

WORKDIR /app
RUN apk add --no-cache make git

COPY . ./
RUN env
RUN ls -la
RUN pwd

RUN CGO_ENABLED=0 go build -a -ldflags '-extldflags "-s -w -static"' ./cmd/alertmanager-bot

# generate clean, final image for end users
FROM alpine:3.15

ENV TEMPLATE_PATHS=/templates/default.tmpl

RUN apk add --update ca-certificates

COPY ./default.tmpl /templates/default.tmpl
COPY --from=builder /app/alertmanager-bot /usr/bin/alertmanager-bot
COPY ./examples/welcome4.png /tmp/welcome4.png

USER 1000

ENTRYPOINT ["/usr/bin/alertmanager-bot"]
