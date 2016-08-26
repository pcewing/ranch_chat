defmodule Chat.Worker do
  @moduledoc """
  The worker process responsible for handling client messages as well as
  forwarding messages to the client from the server.
  """

  use GenServer
  require Logger

  alias Chat.ClientRegistry

  def send_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:send_msg, msg})
  end

  def handle_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:handle_msg, msg})
  end

  def start_link(socket, transport, id) do
    default_state = %{
      socket: socket,
      transport: transport,
      id: id
    }

    GenServer.start_link(__MODULE__, default_state)
  end

  def init(default) do
    ClientRegistry.register({default.id, self})
    {:ok, default}
  end

  def handle_call({:handle_msg, msg}, _from, state) do
    Logger.debug "Broadcasting a message from the client #{inspect state.id}: "
      <> "#{inspect msg}"

    ClientRegistry.get_entries
    |> Stream.reject(fn({id, _pid}) -> id == state.id end)
    |> Enum.each(fn({_id, pid}) -> send_msg(pid, msg) end)

    {:reply, :ok, state}
  end

  def handle_call({:send_msg, msg}, _from, state) do
    state.transport.send(state.socket, msg)
    {:reply, :ok, state}
  end
end
