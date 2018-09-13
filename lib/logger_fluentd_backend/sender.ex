defmodule LoggerFluentdBackend.Sender do
  use GenServer

  defmodule State do
    defstruct socket: nil
  end

  def init(_) do
    # serializer = serializer(options[:serializer] || :msgpack)
    {:ok, %State{socket: nil}}
  end

  def send(tag, data, host, port) do
    IO.inspect(%{data: data, tag: tag, host: host, port: port})
    :ok = GenServer.cast(__MODULE__, {:send, tag, data, host, port})
  end

  # def terminate(_reason, %State{socket: socket}) do
  #   Socket.Stream.close(socket)
  # end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({_, _, _, host, port} = msg, %State{socket: nil} = state) do
    IO.inspect("socket nil")
    IO.inspect(host)
    IO.inspect(port)
    socket = connect(host: host, port: port)
    handle_cast(msg, %State{state | socket: socket})
  end

  def handle_cast({:send, tag, data, _host, _port}, %State{socket: socket} = state) do
    IO.inspect("send")
    IO.inspect(socket)
    packet = serializer(:msgpack).([tag, now(), data])
    IO.inspect(packet)
    Socket.Stream.send!(socket, packet)
    {:noreply, state}
  end

  # def handle_call(call, from, %State{socket: nil, options: options} = state) do
  #   socket = connect(options)
  #   handle_call(call, from, %State{state | socket: socket})
  # end

  defp connect(options) do
    Socket.TCP.connect!(options[:host] || "localhost", options[:port] || 24224, packet: 0)
  end

  defp serializer(:msgpack), do: &Msgpax.pack!/1
  defp serializer(:json), do: &Poison.encode!/1
  defp serializer(f) when is_function(f, 1), do: f

  defp now() do
    {msec, sec, _} = :os.timestamp()
    msec * 1_000_000 + sec
  end
end
