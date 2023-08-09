defmodule ElixirconfChat.Chat.Server do
  use GenServer
  require Logger

  alias __MODULE__, as: Server
  alias ElixirconfChat.Chat.Message

  @initial_state [
    log: [],
    subscribers: %{}
  ]

  # Client

  def start_link(params) do
    initial_state =
      @initial_state
      |> Keyword.merge(params)
      |> Enum.into(%{})

    Logger.debug("Start Chat.Server with initial state: #{inspect initial_state}")

    GenServer.start_link(Server, initial_state, name: :"chat_server_#{initial_state.room_id}")
  end

  def get_state(room_id) do
    call_room(room_id, :get_state)
  end

  def join(room_id, pid) do
    call_room(room_id, {:join, pid})
  end

  def leave(room_id, pid) do
    call_room(room_id, {:leave, pid})
  end

  def post(room_id, message, opts) do
    call_room(room_id, {:post, message, opts})
  end

  def call_room(room_id, message) do
    "chat_server_#{room_id}"
    |> String.to_existing_atom()
    |> GenServer.call(message)
  end

  # Server (callbacks)

  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_call({:post_message, %{} = params}, _from, %{subscribers: %{} = subscribers} = state) do
    case Message.changeset(%Message{}, params) do
      %Ecto.Changeset{valid?: true} = message ->
        new_log = Enum.concat(state.log || [], [message])
        new_state = %{state | log: new_log}
        notify_subscribers(subscribers, {:new_message, message})

        {:reply, :ok, new_state}

      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:join, pid}, _from, %{subscribers: %{} = subscribers} = state) do
    monitor_ref = Process.monitor(pid)
    updated_subscribers = Map.put(subscribers, pid, monitor_ref)

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call({:leave, pid}, _from, %{subscribers: %{} = subscribers} = state) do
    monitor_ref = Map.get(subscribers, pid)
    updated_subscribers = Map.delete(subscribers, pid)

    if is_reference(monitor_ref) && Process.alive?(pid) do
      Process.demonitor(monitor_ref)
    end

    {:reply, :ok, %{state | subscribers: updated_subscribers}}
  end

  def handle_call({:post, message, opts}, _from, %{subscribers: %{} = _subscribers} = state) do
    IO.inspect message
    IO.inspect opts

    {:reply, :ok, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{subscribers: %{} = subscribers} = state) do
    updated_subscribers = Map.delete(subscribers, pid)

    {:noreply, %{state | subscribers: updated_subscribers}}
  end

  # Private functions

  defp notify_subscribers(subscribers, message) do
    Enum.each(subscribers, fn {pid, _monitor_ref} -> send(pid, message) end)
  end
end
