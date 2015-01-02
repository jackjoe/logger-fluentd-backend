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
      opts = [strategy: :simple_one_for_one, max_restarts: 1_000, name: Fluent.Supervisor] # arbitrary "insanely high" number
      Supervisor.start_link(children, opts)
    end
  end

  def start(name, options \\ []) do
    Supervisor.start_child(Fluent.Supervisor, [name, options])
  end

  def send(server, tag, data) do
    GenServer.cast(server, {:send, tag, data})
  end

  def sync_send(server, tag, data, opts \\ [retries: false]) do
    retries = opts[:retries]
    try do
      :ok = GenServer.call(server, {:send, tag, data})
    catch
      :exit, _ ->
        if (not (retries == false or retries == 0) and is_integer(retries)) or retries == true do
         sync_send(server, tag, data, Keyword.merge(opts, retries: (retries == true && true) || retries - 1))
        else
         {:error, :failed}
       end
    end
  end


end
