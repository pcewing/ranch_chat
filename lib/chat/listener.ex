defmodule Chat.Listener do
  @moduledoc """
  Listens to incoming client messages and passes them along to the sibling
  worker process.
  """

  require Logger

  alias Chat.Worker

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)

    # Assign the client an ID.
    id = SecureRandom.uuid
    {:ok, worker_pid} = Worker.start_link(socket, transport, id)

    Logger.debug "client connection established; "
      <> "listener pid = #{inspect self()}; worker pid = #{inspect worker_pid}"

    state = %{
      socket: socket,
      transport: transport,
      client_id: id,
      worker_pid: worker_pid
    }

    listen(state)
  end

  def listen(state) do
    {:ok, length} = wait_for_msg(state)

    read_msg(state, length)

    listen(state)
  end

  @doc """
  Waits for a message on the socket. Once a message arrives, the length header is read
  and the byte length of the message is returned.
  """
  def wait_for_msg(state) do
    case state.transport.recv(state.socket, 4, 5 * 60 * 1_000) do
      {:ok, msg} ->
        <<length :: size(32)>> = msg
        {:ok, length}

      _ ->
        :ok = state.transport.close(state.socket)
    end
  end

  @doc """
  TODO
  """
  def read_msg(state, length) do
    case state.transport.recv(state.socket, length, 5 * 60 * 1_000) do
      {:ok, msg} ->
        case try_decode(msg) do
          {:ok, decoded} -> Worker.handle_msg(state.worker_pid, decoded)
          {:error, _error} -> Logger.error "Failed to decode a message!"
        end

        listen(state)
      _ ->
        :ok = state.transport.close(state.socket)
    end
  end

  def try_decode(msg) do
    try do
      decoded = Chat.Protocol.Msg.decode(msg)
      {:ok, decoded}
    rescue
      error -> {:error, error}
    end
  end
end
