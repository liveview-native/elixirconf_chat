defmodule ElixirconfChatWeb.ActiveUserComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent
  use LiveViewNative.LiveComponent

  alias ElixirconfChat.Chat.Server

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack modclass="opacity-0.75 type-size-x-small">
      <Image system-name="person.2" />
      <Text><%= assigns[:count] %></Text>
    </HStack>
    """
  end

  def render(assigns) do
    IO.inspect(assigns[:count], label: "COMPONENT RENDER")

    ~H"""
    <div>
      <p class="leading-5 text-brand-gray-600 group-hover:text-brand-purple">
        <button phx-click="display_users"><%= assigns[:count] %></button>
      </p>

      <%= if assigns[:show_users_panel] do %>
        <ol>
          <%= Enum.map(assigns[:users], fn user -> %>
            <li><%= user.first_name %> <%= user.last_name %></li>
          <% end) %>
        </ol>
      <% end %>
    </div>
    """
  end

  def preload(list_of_assigns) do
    IO.inspect(list_of_assigns, label: "COMPONENT ASSIGNS")

    Enum.map(list_of_assigns, fn assigns ->
      case assigns do
        %{room_id: room_id} ->
          assigns
          |> Map.put(:count, Server.get_user_count(room_id))
          |> Map.put(:users, Server.get_users(room_id))

        %{count: count} ->
          Map.put(assigns, :count, count)

        %{users: users} ->
          Map.put(assigns, :users, users)

        _assigns ->
          Map.put(assigns, :count, 0)
      end
    end)
  end
end
