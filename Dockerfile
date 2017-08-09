FROM aeons/elixir-dev:1.5.0
MAINTAINER Plataformatec <opensource@plataformatec.com.br>

WORKDIR /usr/src/engine
COPY . /usr/src/engine

ENV MIX_ENV prod

RUN adduser -u 9000 -D app && \
    mix deps.get && \
    mix escript.build && \
    mkdir -p /usr/src/app && \
    mv /usr/src/engine/engine-credo /usr/src/app/engine-credo && \
    rm -rf /usr/src/engine

USER app
VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/engine-credo"]
