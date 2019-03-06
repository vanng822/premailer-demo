FROM golang:1.12-alpine AS build

RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

COPY Gopkg.lock Gopkg.toml /go/src/premailer/
WORKDIR /go/src/premailer
RUN dep ensure -vendor-only

COPY . .

ARG goos
ARG goarm
ARG goarch
RUN GOOS=${goos} GOARM=${goarm} GOARCH=${goarch} go build -o /go/bin/premailer
RUN cd healthcheck && GOOS=${goos} GOARM=${goarm} GOARCH=${goarch} go build -o /go/bin/healthcheck

FROM alpine:latest

WORKDIR /go/src/premailer
ADD VERSION .
COPY --from=build /go/bin/premailer /go/bin/premailer
COPY --from=build /go/bin/healthcheck /go/bin/healthcheck
COPY --from=build /go/src/premailer/templates templates
CMD ["/go/bin/premailer"]

HEALTHCHECK --interval=15s --timeout=2s --retries=3 \
  CMD ["/go/bin/healthcheck"] || exit 1
