defmodule ElixirconfChatWeb.AssignUser do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 2]

  alias ElixirconfChat.Auth

  def on_mount(_key, params, _session, socket) do
    connect_params = get_connect_params(socket)

    with token when is_binary(token) <- Map.get(params, "token", connect_params["token"]),
         {:ok, user_id} <- Auth.verify_token(token),
         %{} = user <- ElixirconfChat.Users.get_user(user_id)
    do
      socket =
        socket
        |> push_event("persist_token", %{token: token})
        |> assign(current_user: user, token: token)

      {:cont, socket}
    else
      _result ->
        {:halt, push_redirect(socket, to: "/")}
    end
  end
end
