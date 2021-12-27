FROM alpine:edge

ENV SPOTIFYD_VERSION="v0.3.3"

RUN apk -U add curl cargo portaudio-dev protobuf-dev openssl-dev \
 && cd /root \
 && curl -sLO https://github.com/Spotifyd/spotifyd/archive/refs/tags/$SPOTIFYD_VERSION.zip \
 && unzip -q *.zip \
 && cd spotifyd* \
 && cargo build --jobs $(grep -c ^processor /proc/cpuinfo) --release \
 && mv ./target/release/spotifyd /usr/local/bin \
 && apk --purge del cargo portaudio-dev protobuf-dev \
 && apk add alsa-lib libgcc \
 && rm -rf /root/spotifyd* /var/cache/apk/* /lib/apk/db/* /root/*.zip /root/.cargo

ENTRYPOINT ["/usr/local/bin/spotifyd", "--no-daemon", "--no-audio-cache"]
