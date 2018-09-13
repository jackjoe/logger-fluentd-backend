defmodule LoggerFluentdBackend.LoggerTest do
  use ExUnit.Case, async: true
  require Logger

  @port 29123
  @host "localhost"

  setup do
    :ok = Application.put_env(:logger, :backends, [LoggerFluentdBackend.Logger])
    :ok = Application.put_env(:logger, :logger_fluentd_backend, host: @host, port: @port)
    Application.ensure_started(:logger)
    MockFluentdServer.start(@port, self())

    :ok
  end

  test "will send message" do
    log = "Will send this debugging message"
    Logger.debug(log)
    assert_receive {:ok, message}, 5000
    assert String.contains?(message, log)
  end

  test "will send a message to the server" do
    log = "Hello TCP"
    LoggerFluentdBackend.Sender.send("", log, @host, @port)
    assert_receive {:ok, message}, 5000
    # IO.inspect(Enum.join(for <<c::utf8 <- msg>>, do: <<c::utf8>>))
    assert String.contains?(message, log)
  end
end
