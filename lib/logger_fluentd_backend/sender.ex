defmodule LoggerFluentdBackend.Sender do
  use GenServer

  defmodule State do
    defstruct socket: nil
  end

  def init(_) do
    # serializer = serializer(options[:serializer] || :msgpack)
    {:ok, %State{socket: nil}}
  end

  def send(tag, data, host, port, serializer) do
    options = [host: host, port: port, serializer: serializer]

    :ok =
      GenServer.cast(
        __MODULE__,
        {:send, tag, data, options}
      )
  end

  def send(tag, data, host, port) do
    options = [host: host, port: port, serializer: :msgpack]

    :ok =
      GenServer.cast(
        __MODULE__,
        {:send, tag, data, options}
      )
  end

  def stop() do
    GenServer.call(__MODULE__, {:stop, []})
  end

  def handle_call({:stop, _}, _from, _state) do
    {:reply, :ok, %State{socket: nil}}
  end

  def terminate(_reason, %State{socket: socket}) do
    :gen_tcp.close(socket)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({_, _, _, options} = msg, %State{socket: nil} = state) do
    socket = connect(options)
    handle_cast(msg, %State{state | socket: socket})
  end

  def handle_cast({:send, tag, data, options}, %State{socket: socket} = state) do
    packet = serializer(options[:serializer]).([tag, now(), data])
    :gen_tcp.send(socket, packet)
    {:noreply, state}
  end

  defp connect(options) do
    IO.inspect(options)

    res =
      :gen_tcp.connect(
        String.to_charlist(options[:host] || "localhost"),
        options[:port] || 24224,
        [:binary, active: false, packet: 0],
        :infinity
      )

    IO.inspect(res)
    res
  end

  defp serializer(:msgpack), do: &Msgpax.pack!/1
  defp serializer(:json), do: &Poison.encode!/1
  defp serializer(f) when is_function(f, 1), do: f

  defp now() do
    {msec, sec, _} = :os.timestamp()
    msec * 1_000_000 + sec
  end
end
