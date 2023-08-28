defmodule ElixirconfChat.Chat do
  alias ElixirconfChat.Repo
  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Chat.Timeslot
  alias ElixirconfChat.Chat.Server

  import Ecto.Query, only: [from: 2]

  @doc """
  Returns all Timeslots with their Rooms preloaded.
  The returned Timeslots are grouped by the day they start on.
  """
  def schedule do
    from(t in Timeslot, preload: [:rooms])
    |> Repo.all()
    |> Enum.group_by(fn %Timeslot{starts_at: starts_at} ->
      case starts_at do
        nil ->
          :pinned

        starts_at ->
          NaiveDateTime.to_date(starts_at)
      end
    end)
  end

  @doc """
  Returns all Rooms.
  """
  def all_rooms do
    Repo.all(Room)
  end

  @doc """
  Fetches a Room by ID.
  """
  def get_room(room_id) do
    room =
      Room
      |> Repo.get(room_id)
      |> Repo.preload(:messages)

    if room do
      %Room{room | server_state: Server.get_state(room_id)}
    else
      nil
    end
  end

  @doc """
  Joins a Room by ID.
  """
  def join_room(room_id, pid) do
    Server.join(room_id, pid)
  end

  @doc """
  Leaves a Room by ID.
  """
  def leave_room(room_id, pid) do
    Server.join(room_id, pid)
  end

  @doc """
  Posts a Message to a Room by ID.
  """
  def post_message(room_id, params) do
    Server.post(room_id, params)
  end

  @doc """
  Creates a new Room using the given `attrs`.
  """
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Room using the given `attrs`.
  """
  def update_room(room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Room.
  """
  def delete_room(room) do
    Repo.delete(room)
  end

  @doc """
  Returns all Timeslots.
  """
  def all_timeslots do
    Repo.all(Timeslot)
  end

  @doc """
  Fetches a Timeslot by ID.
  """
  def get_timeslot(timeslot_id) do
    Repo.get(Timeslot, timeslot_id)
  end

  @doc """
  Creates a new Timeslot using the given `attrs`.
  """
  def create_timeslot(attrs) do
    %Timeslot{}
    |> Timeslot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Timeslot using the given `attrs`.
  """
  def update_timeslot(timeslot, attrs) do
    timeslot
    |> Timeslot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Timeslot.
  """
  def delete_timeslot(timeslot) do
    Repo.delete(timeslot)
  end
end
