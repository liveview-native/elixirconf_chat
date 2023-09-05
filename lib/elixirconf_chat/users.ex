defmodule ElixirconfChat.Users do
  alias Ecto.Multi
  alias ElixirconfChat.Chat.Messages
  alias ElixirconfChat.Repo
  alias ElixirconfChat.Users.User

  @doc """
  Fetches a User by ID.
  """
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc """
  Fetches a User by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Fetches all Users.
  """
  def get_users() do
    User |> Repo.all()
  end

  @doc """
  Creates a new User using the given `attrs`.
  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing User using the given `attrs`.
  """
  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(user) do
    Repo.delete(user)
  end

  @doc """
  Updates an existing User with a `banned_at` timestamp.
  """
  def ban_user!(user_id) do
    Repo.get(User, user_id)
    |> User.changeset(%{banned_at: DateTime.utc_now()})
    |> Repo.update()
    |> case do
      {:ok, user} ->
        Messages.delete_messages_for_user(user.id)

      _ ->
        raise "Error"
    end
  end
end
