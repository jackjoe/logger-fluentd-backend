defmodule LoggerFluentdBackend.Logger do
  @behaviour :gen_event

  alias LoggerFluentdBackend.Sender

  def init(__MODULE__) do
    if Process.whereis(:user) do
      init({:user, []})
    else
      {:error, :ignore}
    end
  end

  def init({_, _}) do
    state = configure([])
    {:ok, state}
  end

  def handle_call({:configure, options}, _) do
    state = configure(options)
    {:ok, :ok, state}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    IO.inspect state
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    IO.inspect msg
    if meet_level?(level, min_level) do
      log_event(level, msg, ts, md, state)
    end

    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  ## Helpers

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min), do: Logger.compare_levels(lvl, min) != :lt

  defp configure(options) do
    env = Application.get_env(:logger, :logger_fluentd_backend, [])
    config = configure_merge(env, options)
    Application.put_env(:logger, :logger_fluentd_backend, config)

    host = Keyword.get(config, :host)
    serializer = Keyword.get(config, :serializer) || :json
    port = Keyword.get(config, :port)
    tag = Keyword.get(config, :tag) || ""
    level = Keyword.get(config, :level)
    # metadata = Keyword.get(config, :metadata, [])

    %{level: level, host: host, port: port, tag: tag, serializer: serializer}
  end

  defp configure_merge(env, options) do
    Keyword.merge(env, options, fn _, _v1, v2 -> v2 end)
  end

  defp log_event(level, msg, _ts, md, %{tag: tag} = state) do
    f =
      case md[:function] do
        {f, a} -> "#{f}/#{a}"
        _ -> ""
      end

    data = %{
      pid: inspect(md[:pid]),
      module: inspect(md[:module]),
      function: f,
      line: inspect(md[:module]),
      level: to_string(level),
      message: to_string(msg),
      payload: md[:payload]
    }

    Sender.send(tag, data, state.host, state.port, state.serializer)
  end
end
