defmodule Fluent.Client do
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def start_link(name, options) do
    GenServer.start_link(__MODULE__, options, name: name)
  end

  def init(options) do
    socket = Socket.TCP.connect!(options[:host] || "localhost",options[:port] || 24224, packet: 0)
    serializer = serializer(options[:serializer] || :msgpack)
    {:ok, {socket, serializer}}
  end

  def handle_cast({:send, tag, data}, state) do
    state = send(tag, data, state)
    {:noreply, state}
  end

  def handle_call({:send, tag, data}, _from, state) do
    state = send(tag, data, state)
    {:reply, :ok, state}
  end

  defp send(tag, data,  {socket, serializer} = state) do
    packet = serializer.([tag, now, data])
    Socket.Stream.send!(socket, packet)
    state
  end

  defp serializer(:msgpack), do: &Msgpax.pack!/1
  defp serializer(:json), do: &Poison.encode!/1
  defp serializer(f) when is_function(f, 1), do: f

  defp now do
    {msec, sec, _ } = :os.timestamp
    msec * 1000000 + sec
  end
end
