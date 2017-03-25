defmodule ChatTest do
  use ExUnit.Case
  doctest Chat

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "connect" do
    host = 'localhost'
    port = 10000
    opts = [:binary, active: false]

    IO.puts("Connecting to the server")
    {:ok, socket} = :gen_tcp.connect(host, port, opts)

    msg = "hello"
    header = <<byte_size(msg)::32>>

    IO.puts("Sending a message")
    :ok = :gen_tcp.send(socket, header <> msg)

    IO.puts("Closing a connection")
    :ok = :gen_tcp.close(socket)
  end
end
