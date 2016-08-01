FROM msaraiva/elixir:1.3.1
MAINTAINER Plataformatec <opensource@plataformatec.com.br>

WORKDIR /usr/src/app
COPY ./engine-credo /usr/src/app/

RUN adduser -u 9000 -D app
USER app
VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/engine-credo /code"]
