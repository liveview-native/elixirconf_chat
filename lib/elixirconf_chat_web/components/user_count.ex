defmodule ElixirconfChatWeb.UserCountComponent do
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
    ~H"""
    <span class="leading-5 text-brand-gray-600 group-hover:text-brand-gray-100">
      <%= assigns[:count] %>
    </span>
    """
  end

  def preload(list_of_assigns) do
    Enum.map(list_of_assigns, fn assigns ->
      case assigns do
        %{room_id: room_id} ->
          Map.put(assigns, :count, Server.get_user_count(room_id))

        %{count: count} ->
          Map.put(assigns, :count, count)

        _assigns ->
          Map.put(assigns, :count, 0)
      end
    end)
  end
end
