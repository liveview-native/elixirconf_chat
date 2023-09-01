defmodule ElixirconfChatWeb.Admin.AdminLive do
  use Phoenix.LiveView

  alias ElixirconfChat.Auth
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  on_mount ElixirconfChatWeb.AssignUser

  # [x] redirect if not admin
  # [x] user role migration
  # [x] list of users
  # [x] ability to ban per user
  # [x] banned_at migration
  # [x] banning a user deletes all user's messages
  # [x] deleted_at migration
  # [x] set deleted_at on messages,
  # [x] in ui, show "deleted" instead of message in chat
  # [ ] update genserver to set deleted_at on unsaved messages and refresh LV

  @impl true
  def mount(_params, _session, socket) do
    case socket.assigns.current_user.role do
      "admin" ->
        users = Users.get_users()
        {:ok, assign(socket, users: users)}

      _ ->
        {:ok, push_redirect(socket, to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <table>
      <tr>
        <td><a href={"/chat?token=#{@token}"}>Go back</a></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>Name</td>
        <td>Email</td>
        <td>&nbsp;</td>
      </tr>
      <%= for user <- @users do %>
        <tr>
          <td><%= user.first_name %> <%= user.last_name %></td>
          <td><%= user.email %></td>
          <td>
            <%= if user.banned_at do %>
              User Banned
            <% else %>
              <a href="" phx-click="ban_user" phx-value-user-id={user.id}>Ban User</a>
            <% end %>
          </td>
        </tr>
      <% end %>
    </table>
    """
  end

  @impl true
  def handle_event("ban_user", %{"user-id" => user_id}, socket) do
    IO.inspect(user_id, label: "USER ID")

    case Users.ban_user!(user_id) do
      {:ok, _user} ->
        {:noreply, socket}

      _ ->
        {:noreply, assign(socket, error: "There was an error banning this user")}
    end
  end
end
