FROM elixir:1.10-alpine
MAINTAINER SourceLevel <support@sourcelevel.io>

WORKDIR /usr/src/engine
COPY . /usr/src/engine

ENV MIX_ENV prod

RUN adduser -u 9000 -D app && \
    apk add --update git && \
    mix local.hex --force && \
    mix deps.get && \
    mix escript.build && \
    mkdir -p /usr/src/app && \
    mv /usr/src/engine/engine-credo /usr/src/app/engine-credo && \
    rm -rf /usr/src/engine

USER app
VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/engine-credo"]
