defmodule ElixirconfChat.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string

    timestamps()
  end

  @allowed_fields ~w(email first_name last_name)a
  @required_fields ~w(email first_name last_name)a

  def changeset(user, attrs) do
    user
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
