FROM debian:bookworm AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates git make g++ \
        libboost-system-dev libboost-thread-dev \
        libboost-serialization-dev libboost-filesystem-dev \
        libboost-program-options-dev \
    && rm -rf /var/lib/apt/lists/*

# Pin the source so rebuilding the image does not silently change Vina.
ARG VINA_COMMIT=bb64e5e26b520569a86360d69248069b5e665b3f
RUN git init /src \
    && cd /src \
    && git remote add origin https://github.com/forlilab/AutoDock-Vina.git \
    && git fetch --depth=1 origin "$VINA_COMMIT" \
    && git checkout --detach FETCH_HEAD \
    && test "$(git rev-parse HEAD)" = "$VINA_COMMIT"

RUN make -C /src/build/linux/release -j2 \
    && /src/build/linux/release/vina --version

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/linux/release/vina /usr/local/bin/vina
COPY --from=build /src/build/linux/release/vina_split /usr/local/bin/vina_split
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /data /work /app/inputs \
    && chown 10001:10001 /data /work
WORKDIR /data
USER 10001:10001

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--help"]
