defmodule ElixirconfChat.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :login_code, :string
    field :login_code_expires_at, :naive_datetime
    field :randomize_code_on_login, :boolean, default: true

    timestamps()
  end

  @optional_fields ~w(login_code login_code_expires_at randomize_code_on_login)a
  @required_fields ~w(email first_name last_name)a
  @allowed_fields @optional_fields ++ @required_fields

  def changeset(user, attrs) do
    user
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
