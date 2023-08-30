defmodule ElixirconfChat.Chat.LobbyServer do
  use GenServer
  require Logger

  alias __MODULE__, as: Server

  @initial_state [
    subscribers: %{}
  ]

  # Client

  def start_link(params) do
    initial_state =
      @initial_state
      |> Keyword.merge(params)
      |> Enum.into(%{})

    Logger.debug("Start Chat.LobbyServer with initial state: #{inspect(initial_state)}")

    GenServer.start_link(Server, initial_state, name: :lobby_server)
  end

  def join(pid) do
    GenServer.call(:lobby_server, {:join, pid})
  end

  def leave(pid) do
    GenServer.call(:lobby_server, {:leave, pid})
  end

  def broadcast(message) do
    GenServer.call(:lobby_server, {:broadcast, message})
  end

  # Server (callbacks)

  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_call({:join, pid}, _from, %{subscribers: %{} = subscribers} = state) do
    Logger.info("Chat.LobbyServer - #{inspect self()} joined")

    monitor_ref = Process.monitor(pid)
    updated_subscribers = Map.put(subscribers, pid, monitor_ref)

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call({:leave, pid}, _from, %{subscribers: %{} = subscribers} = state) do
    Logger.info("Chat.LobbyServer - #{inspect self()} left")

    monitor_ref = Map.get(subscribers, pid)
    updated_subscribers = Map.delete(subscribers, pid)

    if is_reference(monitor_ref) && Process.alive?(pid) do
      Process.demonitor(monitor_ref)
    end

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call({:broadcast, message}, _from, %{subscribers: %{} = subscribers} = state) do
    notify_subscribers(subscribers, message)

    {:reply, :ok, state}
  end

  def handle_info(
        {:DOWN, _ref, :process, pid, _reason},
        %{subscribers: %{} = subscribers} = state
      ) do
    Logger.info("Chat.LobbyServer - #{inspect self()} disconnected")
    updated_subscribers = Map.delete(subscribers, pid)

    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  # Private functions

  defp notify_subscribers(subscribers, message) do
    Enum.each(subscribers, fn {pid, _monitor_ref} -> send(pid, message) end)
  end
end
