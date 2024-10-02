FROM alpine:3.13 AS builder

ARG XMRIG_VERSION='v6.21.1'
WORKDIR /miner

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    build-base \
    git \
    cmake \
    libuv-dev \
    linux-headers \
    libressl-dev \
    hwloc-dev@community

RUN git clone https://github.com/xmrig/xmrig && \
    mkdir xmrig/build && \
    cd xmrig && git checkout ${XMRIG_VERSION}

COPY .build/supportxmr.patch /miner/xmrig
RUN cd xmrig && git apply supportxmr.patch

RUN cd xmrig/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)


FROM alpine:3.13
LABEL owner="ToRxmrig"
LABEL maintainer="@ToRxmrig"

ENV WALLET=webdevthree.329556
ENV POOL=us-east01.miningrigrentals.com:3333
ENV WORKER_NAME=rig0

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    libuv \
    libressl \
    hwloc@community

WORKDIR /xmr
COPY --from=builder /miner/xmrig/build/xmrig /xmr

CMD ["sh", "-c", "./xmrig -a rx/0 --url=$POOL --donate-level=1 --user=$WALLET --pass=$WORKER_NAME -k --coin=monero"]
