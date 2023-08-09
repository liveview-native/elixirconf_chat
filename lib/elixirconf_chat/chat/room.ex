defmodule ElixirconfChat.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirconfChat.Chat.Message
  alias ElixirconfChat.Chat.Timeslot

  schema "rooms" do
    field :title, :string
    field :track, :integer
    field :presenters, {:array, :string}
    field :server_state, :map, virtual: true

    belongs_to :timeslot, Timeslot
    has_many :messages, Message
  end

  @optional_fields ~w(track timeslot_id)a
  @required_fields ~w(title presenters)a
  @allowed_fields @optional_fields ++ @required_fields

  def changeset(room, attrs) do
    room
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
