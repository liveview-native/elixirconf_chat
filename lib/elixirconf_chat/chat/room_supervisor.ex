defmodule ElixirconfChat.Chat.RoomSupervisor do
  use DynamicSupervisor

  alias ElixirconfChat.Chat.Server

  def start_link(room_id) do
    DynamicSupervisor.start_link(__MODULE__, room_id, name: __MODULE__)
  end

  def start_child(room_id) do
    spec = {Server, room_id: room_id}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def which_children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end
