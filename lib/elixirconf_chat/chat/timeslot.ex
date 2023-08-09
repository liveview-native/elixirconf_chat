defmodule ElixirconfChat.Chat.Timeslot do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Utils

  schema "timeslots" do
    field :starts_at, :naive_datetime
    field :ends_at, :naive_datetime
    field :timezone, :string, default: "EST"
    field :formatted_string, :string

    has_many :rooms, Room
  end

  @optional_fields ~w(starts_at ends_at formatted_string)a
  @required_fields ~w(timezone)a
  @allowed_fields @optional_fields ++ @required_fields

  def changeset(room, attrs) do
    room
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
    |> put_formatted_string()
  end

  ###

  defp put_formatted_string(%Ecto.Changeset{valid?: true} = changeset) do
    timezone = get_field(changeset, :timezone)
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)
    formatted_string = Utils.time_range_formatted(starts_at, ends_at, timezone)

    put_change(changeset, :formatted_string, formatted_string)
  end

  defp put_formatted_string(changeset), do: changeset
end
