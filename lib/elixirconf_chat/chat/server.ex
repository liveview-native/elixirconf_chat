defmodule ElixirconfChat.Chat.Server do
  use GenServer
  require Logger

  alias __MODULE__, as: Server
  alias ElixirconfChat.Chat.Message
  alias ElixirconfChat.Chat.LobbyServer

  @initial_state [
    messages: [],
    subscribers: %{}
  ]

  # Client

  def start_link(params) do
    initial_state =
      @initial_state
      |> Keyword.merge(params)
      |> Enum.into(%{})

    Logger.debug("Start Chat.Server with initial state: #{inspect(initial_state)}")

    GenServer.start_link(Server, initial_state, name: :"chat_server_#{initial_state.room_id}")
  end

  def get_state(room_id) do
    call_room(room_id, :get_state)
  end

  def get_user_count(room_id) do
    call_room(room_id, :get_user_count)
  end

  def join(room_id, pid) do
    call_room(room_id, {:join, pid})
  end

  def leave(room_id, pid) do
    call_room(room_id, {:leave, pid})
  end

  def post(room_id, params) do
    call_room(room_id, {:post, params})
  end

  def call_room(room_id, message) do
    "chat_server_#{room_id}"
    |> String.to_existing_atom()
    |> GenServer.call(message)
  end

  def clear_message_queue(room_id) do
    call_room(room_id, :clear_message_queue)
  end

  # Server (callbacks)

  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_call({:post, params}, _from, %{subscribers: %{} = subscribers} = state) do
    case Message.changeset(%Message{}, params) do
      %Ecto.Changeset{valid?: true} = message ->
        message = Ecto.Changeset.apply_changes(message)
        new_messages = Enum.concat(state.messages || [], [message])
        new_state = %{state | messages: new_messages}
        notify_subscribers(subscribers, {:new_message, message})

        {:reply, :ok, new_state}

      _result ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_user_count, _from, %{subscribers: %{} = subscribers} = state) do
    {:reply, Enum.count(subscribers), state}
  end

  def handle_call({:join, pid}, _from, %{room_id: room_id, subscribers: %{} = subscribers} = state) do
    monitor_ref = Process.monitor(pid)
    updated_subscribers = Map.put(subscribers, pid, monitor_ref)

    LobbyServer.broadcast({:room_updated, %{room_id: room_id, users_count: Enum.count(updated_subscribers)}})

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call({:leave, pid}, _from, %{room_id: room_id, subscribers: %{} = subscribers} = state) do
    monitor_ref = Map.get(subscribers, pid)
    updated_subscribers = Map.delete(subscribers, pid)

    LobbyServer.broadcast({:room_updated, %{room_id: room_id, users_count: Enum.count(updated_subscribers)}})

    if is_reference(monitor_ref) && Process.alive?(pid) do
      Process.demonitor(monitor_ref)
    end

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call(:clear_message_queue, _from, state) do
    {:reply, {:ok, []}, %{state | messages: []}}
  end

  def handle_info(
    {:DOWN, _ref, :process, pid, _reason},
    %{room_id: room_id, subscribers: %{} = subscribers} = state
  ) do
    updated_subscribers = Map.delete(subscribers, pid)

    LobbyServer.broadcast({:room_updated, %{room_id: room_id, users_count: Enum.count(updated_subscribers)}})

    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  # Private functions

  defp notify_subscribers(subscribers, message) do
    Enum.each(subscribers, fn {pid, _monitor_ref} -> send(pid, message) end)
  end
end
