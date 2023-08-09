defmodule ElixirconfChat.Auth.Tokens do
  alias Phoenix.Token

  alias ElixirconfChatWeb.Endpoint

  @token_max_age 86400

  def generate(user_id) do
    Token.sign(Endpoint, token_salt(), user_id)
  end

  def verify(token) do
    Token.verify(Endpoint, token_salt(), token, max_age: @token_max_age)
  end

  defp token_salt do
    Application.fetch_env!(:elixirconf_chat, :token_salt)
  end
end
