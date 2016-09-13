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
      <> "listener pid = #{inspect self}; worker pid = #{inspect worker_pid}"

    listen(socket, transport, worker_pid)
  end

  def listen(socket, transport, worker_pid) do
    case transport.recv(socket, 0, 5 * 60 * 1_000) do
      {:ok, msg} ->
        case try_decode(msg) do
          {:ok, decoded} -> Worker.handle_msg(worker_pid, decoded)
          {:error, _error} -> Logger.error "Failed to decode a message!"
        end

        listen(socket, transport, worker_pid)
      _ ->
        :ok = transport.close(socket)
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
