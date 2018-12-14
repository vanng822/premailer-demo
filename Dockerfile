FROM golang:1.9.2-alpine3.6 AS build

RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

COPY Gopkg.lock Gopkg.toml /go/src/premailer/
WORKDIR /go/src/premailer
RUN dep ensure -vendor-only

COPY . .

RUN GOOS=linux GOARM=7 GOARCH=arm go build -o /go/bin/premailer

FROM alpine:latest

RUN apk add --no-cache libc6-compat
RUN apk add --no-cache curl
WORKDIR /go/src/premailer
ADD VERSION .
COPY --from=build /go/bin/premailer /go/bin/premailer
COPY --from=build /go/src/premailer/templates templates
CMD ["/go/bin/premailer"]

HEALTHCHECK --interval=15s --timeout=2s --retries=12 \
  CMD curl --fail localhost:9998/timers || exit 1
