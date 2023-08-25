defmodule ElixirconfChat.Auth do
  alias ElixirconfChat.Auth.LoginCodes
  alias ElixirconfChat.Auth.Tokens
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  @doc """
  Randomizes the login code for a User and updates its
  `login_code_expires_at` field to be 1 hour from now.
  This function is only called when the User has the
  `randomize_code_on_login` field set to `true`.
  """
  def randomize_user_login_code(%User{randomize_code_on_login: true} = user) do
    Users.update_user(user, %{
      login_code: LoginCodes.random_login_code(),
      login_code_expires_at: LoginCodes.expires_at()
    })
  end

  def randomize_user_login_code(user), do: {:ok, user}

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
