defmodule ElixirconfChatWeb.LiveSession do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.Component, only: [assign: 3]

  alias ElixirconfChat.Auth

  def on_mount(_key, params, session, socket) do
    with [_ | _] = global_native_bindings <- Map.get(socket.assigns, :global_native_bindings) |> IO.inspect(),
         token when is_binary(token) <- Keyword.get(global_native_bindings, :token) |> IO.inspect(),
         {:ok, user_id} <- Auth.verify_token(token) |> IO.inspect(),
         %{} = user <- ElixirconfChat.Users.get_user(user_id) |> IO.inspect()
    do
      {:cont, assign(socket, :current_user, user)}
    else
      result ->
        {:cont, socket}
    end
  end
end
