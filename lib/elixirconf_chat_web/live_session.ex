defmodule ElixirconfChatWeb.LiveSession do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.Component, only: [assign: 3]

  alias ElixirconfChat.Auth

  def on_mount(_key, params, session, socket) do
    IO.puts "on_mount called"
    with [_ | _] = global_native_bindings <- Map.get(socket.assigns, :global_native_bindings),
         token when is_binary(token) <- Keyword.get(global_native_bindings, :token),
         {:ok, user_id} <- Auth.verify_token(token),
         %{} = user <- ElixirconfChat.Users.get_user(user_id)
    do
      {:cont, assign(socket, :current_user, user)}
    else
      _result ->
        {:cont, socket}
    end
  end
end
