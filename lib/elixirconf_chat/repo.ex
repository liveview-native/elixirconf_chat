defmodule ElixirconfChat.Repo do
  use Ecto.Repo,
    otp_app: :elixirconf_chat,
    adapter: Ecto.Adapters.Postgres
end
