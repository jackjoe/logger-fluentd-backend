defmodule LoggerFluentdBackend.Logger do
  @behaviour :gen_event

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
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) || Logger.compare_levels(level, min_level) != :lt do
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

  defp configure(options) do
    env = Application.get_env(:logger, :logger_fluentd_backend, [])
    fluent = configure_merge(env, options)
    Application.put_env(:logger, :logger_fluentd_backend, fluent)

    host = Keyword.get(fluent, :host)
    serializer = Keyword.get(fluent, :serializer)
    port = Keyword.get(fluent, :port)
    tag = Keyword.get(fluent, :tag) || ""
    level = Keyword.get(fluent, :level)
    metadata = Keyword.get(fluent, :metadata, [])

    %{metadata: metadata, level: level, host: host, port: port, tag: tag, serializer: serializer}
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

    LoggerFluentdBackend.Sender.send(tag, data, state.host, state.port, state.serializer)
  end
end
