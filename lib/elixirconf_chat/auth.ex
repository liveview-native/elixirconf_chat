defmodule ElixirconfChat.Auth do
  alias ElixirconfChat.Auth.LoginCodes
  alias ElixirconfChat.Auth.Tokens
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

  @doc """
  Generates a session token for a User given its ID.
  """
  def generate_token(user_id) do
    Tokens.generate(user_id)
  end

  @doc """
  Verifies a session token.
  """
  def verify_token(token) do
    Tokens.verify(token)
  end
end
