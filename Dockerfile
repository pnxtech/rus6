FROM rust:latest as builder

ENV LIBDIR /usr/lib/redis/modules
ENV DEPS "python python-setuptools python-pip wget unzip build-essential clang-6.0 cmake"

# Set up a build environment
RUN set -ex;\
    deps="$DEPS";\
    apt-get update; \
    apt-get install -y --no-install-recommends $deps;\
    pip install rmtest

# Build the source
ADD . /RUS6
WORKDIR /RUS6
RUN set -ex;\
    cargo build --release;\
    mv target/release/librus6.so target/release/rus6.so

# Package the runner
FROM redis:latest
ENV LIBDIR /usr/lib/redis/modules
WORKDIR /data
RUN set -ex;\
    mkdir -p "$LIBDIR";
COPY --from=builder /REJSON/target/release/rus6.so "$LIBDIR"

CMD ["redis-server", "--loadmodule", "/usr/lib/redis/modules/rus6.so"]
