RUN_STANDARD := docker run --rm -v `pwd`:/app -w /app hexpm/elixir:1.15.4-erlang-26.0.2-alpine-3.18.2

all: build

up:
	docker compose up

build:
	$(RUN_STANDARD) sh -c 'apk update && mix do local.rebar --force, local.hex --force, \
                           		deps.get, \
                           		deps.compile --force, \
                           		compile --plt'

testing:
	$(RUN_STANDARD) mix test

iex:
	$(RUN_STANDARD) iex -S mix

format:
	$(RUN_STANDARD) mix format
