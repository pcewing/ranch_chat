defmodule ChatClient do
  use GenServer

  require Logger

  @default_host 'localhost'
  @default_port 10000
  @default_opts [:binary, active: false]

  def start_link, do:
    GenServer.start_link(__MODULE__, Map.new)

  def init(state), do:
    {:ok, state}

  def connect(pid), do:
    GenServer.call(pid, :connect)

  def disconnect(pid), do:
    GenServer.call(pid, :disconnect)

  def send_message(pid, message), do:
    GenServer.call(pid, {:send_message, message})

  def handle_call(:connect, _, state) do
    Logger.info "connecting to the server at #{@default_host}:#{@default_port}"
    {:ok, socket} = :gen_tcp.connect(@default_host, @default_port, @default_opts)
    {:reply, :ok, Map.put(state, :socket, socket)}
  end

  def handle_call(:disconnect, _, state) do
    Logger.info "disconnecting from the server"
    :ok = :gen_tcp.close(state.socket)
    {:reply, :ok, state}
  end

  def handle_call({:send_message, message}, _, state) do
    Logger.info "sending a message to the server"
    header = <<byte_size(message)::32>>
    :ok = :gen_tcp.send(state.socket, header <> message)
    {:reply, :ok, state}
  end
end
