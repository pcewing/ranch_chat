defmodule Chat.Listener do
  @moduledoc """
  Listens to incoming client messages and passes them along to the sibling
  worker process.
  """

  @header_byte_length 4
  @header_bit_length 32

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

    Logger.info "client connected, assigned id = #{id}"

    state = %{
      socket: socket,
      transport: transport,
      client_id: id,
      worker_pid: worker_pid,
      error: nil
    }

    listen(state)
  end

  def listen(state) do
    Logger.info "listening for an incoming message from client #{state.client_id}"

    case wait_for_msg(state) do
      {:ok, msg_length} ->
        Logger.info "message received from client #{state.client_id}, length = #{msg_length}"
        case read_msg(state, msg_length) do
          {:ok, message} ->
            Logger.info "message contents = #{inspect(message)}"
            listen(state)
          :closed ->
            Logger.info "client disconnected"
            :ok
        end

      :closed ->
        Logger.info "client disconnected"
        :ok
    end
  end

  @doc """
  TODO
  """
  def wait_for_msg(state) do
    case state.transport.recv(state.socket, @header_byte_length, 5 * 60 * 1_000) do
      {:ok, header} ->
        <<msg_length::size(@header_bit_length)>> = header
        {:ok, msg_length}
      _ ->
        :ok = state.transport.close(state.socket)
        :closed
    end
  end

  @doc """
  TODO
  """
  def read_msg(state, msg_length) do
    case state.transport.recv(state.socket, msg_length, 5 * 60 * 1_000) do
      {:ok, msg} ->
        {:ok, msg}
      _ ->
        :ok = state.transport.close(state.socket)
        :closed
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
