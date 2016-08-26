defmodule Chat.Acceptor do
  @moduledoc """
  Accepts client connections and spawns listener processes to accomodate them.
  """

  alias Chat.Listener

  def start_link do
    opts = [port: Application.get_env(:chat, :port)]

    {:ok, _} = :ranch.start_listener(
      :chat,
      100,
      :ranch_tcp,
      opts,
      Listener,
      []
    )
  end
end
