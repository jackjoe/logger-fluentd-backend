defmodule LoggerFluentdBackend.LoggerTest do
  use ExUnit.Case, async: true
  require Logger

  # @system_name "test_system_name"
  @port 29123

  setup do
    :ok = Application.put_env(:logger, :backends, [LoggerFluentdBackend.Logger])
    :ok = Application.put_env(:logger, :logger_fluentd_backend, host: "localhost", port: @port)
    Application.ensure_started(:logger)
    MockFluentdServer.start(@port, self())

    # on_exit(fn ->
    #   Application.stop(:logger)
    # end)

    :ok
  end

  test "will send message" do
    log = "Will send this debugging message"
    Logger.debug(log)
    assert_receive {:ok, message}, 5000
    assert String.contains?(message, log)
  end
end
