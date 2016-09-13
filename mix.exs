defmodule Chat.Mixfile do
  use Mix.Project

  def project do
    [app: :chat,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :ranch],
     mod: {Chat, []}]
  end

  defp deps do
    [
      {:secure_random, "~> 0.5.0"},
      {:ranch, "~> 1.2"},
      {:exprotobuf, "~> 1.2"},
      {:credo, "~> 0.4.9"} # Not necessary but useful.
    ]
  end
end
