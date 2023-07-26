defmodule ElixirconfChat.Auth do
  alias ElixirconfChat.Auth.LoginCodes
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  @doc """
  Randomizes the login code for a User and updates its
  `login_code_expires_at` field to be 1 hour from now.
  """
  def randomize_user_login_code(%User{} = user) do
    Users.update_user(user, %{
      login_code: LoginCodes.random_login_code(),
      login_code_expires_at: LoginCodes.expires_at()
    })
  end
end
