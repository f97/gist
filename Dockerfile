FROM alpine:3.18 AS build

RUN apk update && \
    apk add --no-cache \
    make \
    gcc \
    musl-dev \
    libstdc++

COPY --from=golang:1.19-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

COPY --from=node:18-alpine /usr/local/ /usr/local/
ENV NODE_PATH="/usr/local/lib/node_modules"
ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /opengist

COPY . .

RUN make


FROM alpine:3.18 as run

RUN apk add --no-cache openssh git libstdc++

RUN addgroup -S opengist && \
    adduser -S -G opengist -H -s /bin/ash -g 'Opengist User' opengist

WORKDIR /app/opengist

COPY --from=build --chown=opengist:opengist /opengist/opengist .
COPY --from=build --chown=opengist:opengist /opengist/docker ./docker

EXPOSE 6157 2222
VOLUME /opengist
ENTRYPOINT ["./docker/entrypoint.sh"]
