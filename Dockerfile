FROM alpine:latest as builder

ARG SPOTIFYD_VERSION="0.3.3"

RUN apk update && \
    apk --no-cache add \
        cargo \
        portaudio-dev \
        protobuf-dev \
        openssl-dev \
        alsa-lib \
        libgcc \
    && cd /root \
    && wget https://github.com/Spotifyd/spotifyd/archive/refs/tags/v$SPOTIFYD_VERSION.zip \
    && unzip -q *.zip \
    && cd spotifyd* \
    && cargo build --jobs $(grep -c ^processor /proc/cpuinfo) --release

FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
        alsamixer \
    && rm -rf /var/cache/apk/*

COPY --from=builder /root/spotifyd/target/release/spotifyd /app/

ENTRYPOINT ["/app/spotifyd", "--no-daemon", "--no-audio-cache"]
