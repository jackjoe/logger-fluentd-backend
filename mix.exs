defmodule LoggerFluentdBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :logger_fluentd_backend,
      version: "0.0.6",
      elixir: ">= 1.6.0",
      description: "A Fluentd backend for Elixir Logger",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      name: "Logger Fluentd Backend",
      source_url: "https://github.com/jackjoe/logger-fluentd-backend"
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :msgpax, :socket], mod: {LoggerFluentdBackend, []}]
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:msgpax, "~> 2.4"},
      {:jason, "~> 1.1"},
      {:socket, "~> 0.3"}
    ]
  end

  defp package do
    [
      maintainers: ["Pieter Michels", "Jeroen Bourgois"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jackjoe/logger-fluentd-backend"}
    ]
  end
end
