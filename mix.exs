defmodule LoggerFluentdBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :logger_fluentd_backend,
      version: "0.0.1",
      elixir: ">= 1.5.0",
      description: "A Fluentd backend for Elixir Logger",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [], mod: {LoggerFluentdBackend, []}]
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
      {:socket, "~> 0.3.13"},
      {:poison, "~> 3.1.0"},
      {:msgpax, "~> 2.1.1"}
    ]
  end

  defp package do
    [
      maintainers: ["Pieter Michels", "Jeroen Bourgois"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/jackjoe/logger-fluentd-backend"}
    ]
  end
end
