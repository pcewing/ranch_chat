defmodule Chat.Protocol do
  use Protobuf, from: Path.expand("../../protocol.proto", __DIR__),
                use_package_names: true,
                namespace: :"Elixir"
end
