defmodule LoggerFluentdBackend do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(LoggerFluentdBackend.Sender, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    # arbitrary "insanely high" number
    opts = [strategy: :simple_one_for_one, max_restarts: 1_000, name: Fluent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start(name, options \\ []) do
    Supervisor.start_child(LoggerFluentdBackend.Supervisor, [name, options])
  end

  def send(server, tag, data) do
    GenServer.cast(server, {:send, tag, data})
  end

  # def sync_send(server, tag, data, opts \\ [retries: false]) do
  #   retries = opts[:retries]
  #
  #   try do
  #     :ok = GenServer.call(server, {:send, tag, data})
  #   catch
  #     :exit, _ ->
  #       if (!(retries == false || retries == 0) && is_integer(retries)) || retries == true do
  #         opts = Keyword.merge(opts, retries: (retries == true && true) || retries - 1)
  #         sync_send(server, tag, data, opts)
  #       else
  #         {:error, :failed}
  #       end
  #   end
  # end
end
