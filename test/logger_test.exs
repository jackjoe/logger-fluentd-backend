defmodule LoggerFluentdBackend.LoggerTest do
  use ExUnit.Case, async: true
  require Logger

  @port 29123
  @host "localhost"

  setup do
    Application.put_env(:logger, :backends, [LoggerFluentdBackend.Logger])
    Application.put_env(:logger, :logger_fluentd_backend, host: @host, port: @port)

    Application.ensure_started(:logger)

    # Application.load(:logger_fluentd_backend)
    #
    # for app <- Application.spec(:logger_fluentd_backend, :applications) do
    #   Application.ensure_all_started(app)
    # end

    MockFluentdServer.start(@port, self())

    :ok
  end

  test "will send message" do
    log = "Will send this debugging message"
    Logger.debug(log)
    assert_receive {:ok, message}, 2000
    assert String.contains?(message, log)
  end
end
