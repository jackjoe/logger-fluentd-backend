# LoggerFluentdBackend

[![Hex.pm](https://img.shields.io/hexpm/v/logger_fluentd_backend.svg?maxAge=2592000)](https://hex.pm/packages/logger_fluentd_backend)
[![Hex.pm](https://img.shields.io/hexpm/dt/logger_fluentd_backend.svg)](https://hex.pm/packages/logger_fluentd_backend)

<!-- [![Build Status](https://travis-ci.org/larskrantz/logger_fluentd_backend.svg?branch=master)](https://travis-ci.org/larskrantz/logger_fluentd_backend) -->

A Fluentd backend for [Elixir Logger](http://elixir-lang.org/docs/stable/logger/Logger.html).

## Installation

Available in [Hex](https://hex.pm/packages/logger_fluentd_backend). The package can be installed as:

Add `logger_fluentd_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:logger_fluentd_backend, "~> 0.0.3"}]
end
```

After Elixir 1.4, just ensure `Logger` is in `extra_applications`:

```elixir
def application do
  [extra_applications: [:logger]]
end
```

In your `config.exs` (or in your `#{Mix.env}.exs`-files):

```elixir
config :logger, :logger_fluentd_backend,
  serializer: :msgpack,
  tag: "",
  level: :debug,
  host: "localhost",
  port: 24224
```

Then config `:logger` to use the `LoggerFluentdBackend.Logger`:

```elixir
config :logger,
  backends: [ :console,
    LoggerFluentdBackend.Logger
  ],
  level: :debug
```
