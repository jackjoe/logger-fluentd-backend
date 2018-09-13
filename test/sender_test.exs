defmodule SenderTest do
  use ExUnit.Case

  test "will send a message to the server" do
    port = 28000
    host = "localhost"
    MockFluentdServer.start(port, self())
    LoggerFluentdBackend.Sender.stop()
    LoggerFluentdBackend.Sender.send("", "Hello TCP", host, port)
    assert_receive {:ok, message}, 5000
    assert String.contains?(message, "Hello TCP")
  end
end
