defmodule Chat do
  @moduledoc """
  The main application supervisor.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Chat.ClientRegistry, []),
      worker(Chat.Acceptor, [])
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
