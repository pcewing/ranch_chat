defmodule Chat.Acceptor do
  @moduledoc """
  Accepts client connections and spawns listener processes to accomodate them.
  """

  require Logger

  def start_link do
    port = Application.get_env(:chat, :port)

    Logger.info("listening for client connections on port #{port}")

    opts = [port: port]

    {:ok, _} = :ranch.start_listener(
      :chat,
      100,
      :ranch_tcp,
      opts,
      Chat.Listener,
      []
    )
  end
end
