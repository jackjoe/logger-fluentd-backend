defmodule SenderTest do
  use ExUnit.Case

  test "will send a message to the server" do
    port = 28000
    host = "localhost"
    MockFluentdServer.start(port, self())
    LoggerFluentdBackend.Sender.send("", "Hello TCP", host, port)
    # assert_receive {:ok, msg}, 5000
    # IO.inspect(Enum.join(for <<c::utf8 <- msg>>, do: <<c::utf8>>))
    assert_receive {:ok, "Hello TCP"}, 5000
  end
end
