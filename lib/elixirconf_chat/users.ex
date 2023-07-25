defmodule ElixirconfChat.Users do
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
end
