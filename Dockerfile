FROM golang:1.9.2-alpine3.6 AS build

RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

COPY Gopkg.lock Gopkg.toml /go/src/premailer/
WORKDIR /go/src/premailer
RUN dep ensure -vendor-only

COPY . .

RUN go build -o /go/bin/premailer

FROM alpine:latest

RUN apk add --no-cache libc6-compat
WORKDIR /go/src/premailer
RUN mkdir -p /go/bin
COPY --from=build /go/bin/premailer /go/bin/premailer
COPY --from=build /go/src/premailer/templates templates
CMD ["/go/bin/premailer"]
