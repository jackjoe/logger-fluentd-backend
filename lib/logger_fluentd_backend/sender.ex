defmodule LoggerFluentdBackend.Sender do
  use GenServer

  defmodule State do
    defstruct socket: nil
  end

  def init(_) do
    # serializer = serializer(options[:serializer] || :msgpack)
    {:ok, %State{}}
  end

  def send(tag, data, host, port) do
    :ok = GenServer.cast(__MODULE__, {:send, tag, data, host, port})
  end

  # def terminate(_reason, state) do
  #   :gen_udp.close(state.socket)
  # end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({_, _, _, host, port} = msg, %State{socket: nil} = state) do
    socket = connect(host: host, port: port)
    handle_cast(msg, %State{state | socket: socket})
  end

  def handle_cast({:send, tag, data, host, port}, %State{socket: socket} = state) do
    packet = serializer(:msgpack).([tag, now(), data])
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
