defmodule LoggerFluentdBackend.Sender do
  use GenServer

  defmodule State do
    defstruct socket: nil, options: [], serializer: :msgpack
  end

  def init(options) do
    serializer = serializer(options[:serializer] || :msgpack)
    {:ok, %State{options: options, serializer: serializer}}
  end

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def start_link(name, options) do
    GenServer.start_link(__MODULE__, options, name: name)
  end

  def handle_cast(msg, %State{socket: nil, options: options} = state) do
    socket = connect(options)
    handle_cast(msg, %State{state | socket: socket})
  end

  def handle_cast({:send, tag, data}, state) do
    state = send(tag, data, state)
    {:noreply, state}
  end

  def handle_call(call, from, %State{socket: nil, options: options} = state) do
    socket = connect(options)
    handle_call(call, from, %State{state | socket: socket})
  end

  def handle_call({:send, tag, data}, _from, state) do
    state = send(tag, data, state)
    {:reply, :ok, state}
  end

  defp connect(options) do
    Socket.TCP.connect!(options[:host] || "localhost", options[:port] || 24224, packet: 0)
  end

  defp send(tag, data, %State{socket: socket, serializer: serializer} = state) do
    packet = serializer.([tag, now, data])
    Socket.Stream.send!(socket, packet)
    state
  end

  defp serializer(:msgpack), do: &Msgpax.pack!/1
  defp serializer(:json), do: &Poison.encode!/1
  defp serializer(f) when is_function(f, 1), do: f

  defp now do
    {msec, sec, _} = :os.timestamp()
    msec * 1_000_000 + sec
  end
end
