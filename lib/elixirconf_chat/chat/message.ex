defmodule ElixirconfChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  schema "messages" do
    field :body, :string
    field :posted_at, :naive_datetime
    field :posted_by, :string
    field :deleted_at, :naive_datetime

    timestamps()

    belongs_to :room, Room
    belongs_to :user, User
  end

  @optional_fields ~w(room_id user_id)a
  @required_fields ~w(body posted_at posted_by)a
  @allowed_fields @optional_fields ++ @required_fields

  def changeset(room, attrs) do
    room
    |> cast(attrs, @allowed_fields)
    |> put_posted_by()
    |> validate_required(@required_fields)
  end

  ###

  defp put_posted_by(%Ecto.Changeset{valid?: true} = changeset) do
    user_id = get_field(changeset, :user_id)

    case Users.get_user(user_id) do
      nil ->
        add_error(changeset, :user_id, "User not found")

      user ->
        put_change(changeset, :posted_by, "#{user.first_name} #{user.last_name}")
    end
  end

  defp put_posted_by(changeset), do: changeset
end
