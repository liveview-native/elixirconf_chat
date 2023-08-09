defmodule ElixirconfChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Users.User

  schema "messages" do
    field :body, :string

    belongs_to :room, Room
    belongs_to :user, User
  end

  @optional_fields ~w()a
  @required_fields ~w(body room_id user_id)a
  @allowed_fields @optional_fields ++ @required_fields

  def changeset(room, attrs) do
    room
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
