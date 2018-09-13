defmodule LoggerFluentdBackend.Logger do
  use GenEvent

  def init(_) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      config = configure([])
      {:ok, fluent} = LoggerFluentdBackend.Sender.start_link(host: config.host, port: config.port)
      {:ok, put_in(config[:fluent], fluent)}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, %{fluent: fluent}) do
    {:ok, :ok, put_in(configure(options)[:fluent], fluent)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end

    {:ok, state}
  end

  ## Helpers

  defp configure(options) do
    env = Application.get_env(:logger, :logger_fluentd_backend, [])
    fluent = configure_merge(env, options)
    Application.put_env(:logger, :logger_fluentd_backend, fluent)

    host = Keyword.get(fluent, :host)
    port = Keyword.get(fluent, :port)
    tag = Keyword.get(fluent, :tag) || ""
    level = Keyword.get(fluent, :level)
    metadata = Keyword.get(fluent, :metadata, [])
    %{metadata: metadata, level: level, host: host, port: port, tag: tag}
  end

  defp configure_merge(env, options) do
    Keyword.merge(env, options, fn _, _v1, v2 -> v2 end)
  end

  defp log_event(level, msg, _ts, md, %{fluent: fluent, tag: tag}) do
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

    LoggerFluentdBackend.send(fluent, tag, data)
  end
end
