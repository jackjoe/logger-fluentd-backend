defmodule Fluent.Mixfile do
  use Mix.Project

  def project do
    [
      app: :logger_fluentd_backend,
      version: "0.0.1",
      elixir: ">= 1.5.0",
      description: "fluentd logger backend",
      package: package,
      deps: deps
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    test_apps = (Mix.env() == :test && [:porcelain]) || []
    [applications: test_apps ++ [:logger, :poison, :msgpax, :socket], mod: {Fluent.App, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:socket, "~> 0.2.0"},
      {:poison, "~> 1.3.0"},
      {:msgpax, "~> 0.6.0"},
      {:porcelain, "~> 2.0.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Yurii Rashkovskii", "Jack + Joe"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/jackjoe/logger-fluentd-backend"}
    ]
  end
end
