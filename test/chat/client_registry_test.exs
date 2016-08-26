defmodule ClientRegistryTest do
  use ExUnit.Case
  alias Chat.ClientRegistry
  
  doctest Chat.ClientRegistry


  test "register a client" do
    client_id = SecureRandom.uuid

    :ok = ClientRegistry.register({client_id, self})
    entries = ClientRegistry.get_entries
    assert Map.has_key?(entries, client_id)
  end

  test "unregister a client" do
    client_id = SecureRandom.uuid

    :ok = ClientRegistry.register({client_id, self})
    entries = ClientRegistry.get_entries
    assert Map.has_key?(entries, client_id)

    :ok = ClientRegistry.unregister(client_id)
    entries = ClientRegistry.get_entries
    assert not Map.has_key?(entries, client_id)
  end

  test "unregister a client that isn't registered" do
    client_id = SecureRandom.uuid

    entries = ClientRegistry.get_entries
    assert not Map.has_key?(entries, client_id)

    :ok = ClientRegistry.unregister(client_id)
  end
end
