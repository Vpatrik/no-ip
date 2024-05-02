ARG ALPINE_VERSION=3.16

FROM alpine:${ALPINE_VERSION} AS builder

WORKDIR /src

RUN 	   apk update 	                                                                  \
      && apk add wget gcc make libc-dev git curl                                          \
      && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y          \
      && wget https://dmej8g5cpdyqd.cloudfront.net/downloads/noip-duc_3.0.0.tar.gz        \
      && tar xf noip-duc_3.0.0.tar.gz                                              \
      && rm noip-duc_3.0.0.tar.gz                                                  \
      && mv noip* noip_src                                                                \
      && git clone https://github.com/0xFireWolf/STUNExternalIP.git                       \
      && cd STUNExternalIP                                                                \
      && sed -i 's/#include <time.h>/#include <sys\/time.h>\n#include <time.h>/' STUNExternalIP.c    \
      && make

WORKDIR noip_src


ENV PATH="/root/.cargo/bin:${PATH}"
RUN  cargo build --release

FROM alpine:${ALPINE_VERSION}

RUN       apk add --no-cache expect iputils    \
      &&  if [ ! -d /usr/local/etc ]; then mkdir -p /usr/local/etc;fi \
      &&  mkdir /config

RUN addgroup noip && adduser -DH -G noip noip && chown noip /config


USER noip

WORKDIR /scripts/

COPY --from=builder /src/STUNExternalIP/STUNExternalIP /usr/local/bin
COPY --from=builder /src/noip_src/target/release/noip-duc /usr/local/bin
COPY scripts/* /scripts/


ENTRYPOINT ["/scripts/start_commands.sh"]



