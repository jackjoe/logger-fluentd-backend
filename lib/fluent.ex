defmodule Fluent do

  defmodule App do
    use Application

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        # Define workers and child supervisors to be supervised
        worker(Fluent.Client, [])
      ]

      # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
      # for other strategies and supported options
      opts = [strategy: :simple_one_for_one, name: Fluent.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end

  def start(name, options \\ []) do
    Supervisor.start_child(Fluent.Supervisor, [name, options])
  end

  def send(server, tag, data) do
    GenServer.cast(server, {:send, tag, data})
  end


end
