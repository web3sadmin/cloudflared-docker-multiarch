# use a builder image for building cloudflare
ARG TARGET_GOOS
ARG TARGET_GOARCH
FROM golang:1.18.1 as builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    TARGET_GOOS=${TARGET_GOOS} \
    TARGET_GOARCH=${TARGET_GOARCH}
    
LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
COPY . .

# compile cloudflared
RUN make cloudflared

# use debian as the base image
#FROM debian:10
#FROM armhf/alpine:latest
#FROM arm32v7/alpine:latest
FROM armhf/alpine:3.14

# copy our compiled binary
COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/
RUN apt update && apt install -y ca-certificates

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
