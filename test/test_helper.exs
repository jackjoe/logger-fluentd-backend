defmodule MockFluentdServer do
  def start(port, receiver) do
    # IO.puts(">> MockFluentServer on ")
    # IO.inspect(receiver)
    spawn(fn -> server(port, receiver) end)
    :timer.sleep(10)
  end

  def server(port, receiver) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    loop_acceptor(socket, receiver)
  end

  defp loop_acceptor(socket, receiver) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client, receiver)
    loop_acceptor(socket, receiver)
  end

  def serve(socket, receiver) do
    data = socket |> read_line()
    # IO.puts("will send from server")
    # IO.inspect(receiver)
    send(receiver, {:ok, data})
    :gen_tcp.close(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end
end

ExUnit.start()
