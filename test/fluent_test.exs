defmodule Fluent.Test do
  use ExUnit.Case
  alias Porcelain.Process, as: Proc

  setup do
    shutdown
    goon = System.find_executable("goon")
    if goon == nil do
      raise "Can't find goon, required for testing, you can find it here https://github.com/alco/goon#goon (to install, go get github.com/alco/goon)"
    end
    fluentd = System.find_executable("fluentd")
    if fluentd == nil do
      raise "Can't find fluentd, required for testing"
    end
    proc = Porcelain.spawn(fluentd, ["-c", Path.join(Path.dirname(__ENV__.file), "fluent.conf"),"-q"], out: :stream, in: "")
    on_exit fn ->
      shutdown(proc)
    end
    {:ok, fluent} = connect
    on_exit fn  ->
      Process.exit(fluent, :normal)
    end
    {:ok, %{proc: proc, fluent: fluent}}
  end

  test "sending data to fluentd", %{proc: proc, fluent: fluent} do
    %Proc{out: out} = proc
    Fluent.send(fluent, "tag", %{message: "passed"})
    Fluent.send(fluent, "anothertag", %{message: "passed, too"})
    assert Enum.at(out, 0) =~ ~r/tag:\s+{"message":"passed"}/
    assert Enum.at(out, 0) =~ ~r/anothertag:\s+{"message":"passed, too"}/
  end

  defp connect do
    try do
      Socket.TCP.connect!("localhost", 64224, packet: 0)
      Fluent.Client.start_link(port: 64224)
    rescue Socket.Error ->
      :timer.sleep(500)
      connect
    end
  end

  defp shutdown, do: shutdown(nil)
  defp shutdown(_proc) do
    System.cmd("sh", ["-c","ps ax | grep fluentd | grep \"#{Path.join(Path.dirname(__ENV__.file), "fluent.conf")}\" | grep -v grep | awk -F' ' '{print $1;}' | xargs kill -9"])
  end
end
