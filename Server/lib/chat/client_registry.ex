defmodule Chat.ClientRegistry do
  @moduledoc """
  A very basic process registry.
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, Map.new, name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end

  def register({id, pid}) do
    GenServer.call(__MODULE__, {:register, {id, pid}})
  end

  def unregister(id) do
    GenServer.call(__MODULE__, {:unregister, id})
  end

  def get_entries do
    GenServer.call(__MODULE__, :get_entries)
  end

  def handle_call({:register, {id, pid}}, _from, state) do
    {:reply, :ok, Map.put(state, id, pid)}
  end

  def handle_call({:unregister, id}, _from, state) do
    {:reply, :ok, Map.delete(state, id)}
  end

  def handle_call(:get_entries, _from, state) do
    {:reply, state, state}
  end
end
