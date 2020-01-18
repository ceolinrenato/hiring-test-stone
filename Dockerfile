
FROM elixir:1.9.0-alpine as build

ARG DATABASE_URL
ARG SECRET_KEY_BASE
ARG BASIC_AUTH_USERNAME
ARG BASIC_AUTH_PASSWORD

# install build dependencies
RUN apk add --update git build-base

# # prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod
ENV DATABASE_URL=$DATABASE_URL
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV BASIC_AUTH_USERNAME=$BASIC_AUTH_USERNAME
ENV BASIC_AUTH_PASSWORD=$BASIC_AUTH_PASSWORD

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/hiring_test_stone ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

ENTRYPOINT ["bin/hiring_test_stone", "start"]