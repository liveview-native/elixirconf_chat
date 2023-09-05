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

  def render(%{sidebar: false} = assigns) do
    ~H"""
    <div>
      <div class="leading-5 text-brand-gray-600">
        <button class="flex items-center gap-x-2 p-2 rounded-lg border-2 border-transparent hover:bg-brand-gray-50 hover:border-brand-gray-500 outline-none focus-visible:outline-2 focus-visible:outline-brand-purple focus-visible:outline-offset-2" phx-click="show_display_users_modal">
          <svg
            class="w-4 h-4 fill-brand-gray-500 group-hover:fill-brand-purple"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            width="16"
            height="16"
          >
            <path d="M2 22C2 17.5817 5.58172 14 10 14C14.4183 14 18 17.5817 18 22H16C16 18.6863 13.3137 16 10 16C6.68629 16 4 18.6863 4 22H2ZM10 13C6.685 13 4 10.315 4 7C4 3.685 6.685 1 10 1C13.315 1 16 3.685 16 7C16 10.315 13.315 13 10 13ZM10 11C12.21 11 14 9.21 14 7C14 4.79 12.21 3 10 3C7.79 3 6 4.79 6 7C6 9.21 7.79 11 10 11ZM18.2837 14.7028C21.0644 15.9561 23 18.752 23 22H21C21 19.564 19.5483 17.4671 17.4628 16.5271L18.2837 14.7028ZM17.5962 3.41321C19.5944 4.23703 21 6.20361 21 8.5C21 11.3702 18.8042 13.7252 16 13.9776V11.9646C17.6967 11.7222 19 10.264 19 8.5C19 7.11935 18.2016 5.92603 17.041 5.35635L17.5962 3.41321Z">
            </path>
          </svg>
          <span><%= assigns[:count] %></span>
        </button>
      </div>

      <%= if assigns[:show_display_users_modal] and assigns[:count] > 0 do %>
        <div
          class="absolute left-0 top-0 w-full h-full py-4 px-8 bg-white overflow-scroll rounded-[32px] outline-none focus-visible:ring-2 focus-visible:ring-brand-purple"
          id={"room_#{assigns[:room_id]}_attendees"}
        >
          <div class="flex items-center justify-between mb-4">
          <h3 class="font-medium text-xl">Room Participants</h3>
            <button class="p-1 border-2 border-brand-gray-800 rounded-lg group hover:bg-brand-purple outline-none focus-visible:ring-2 focus-visible:ring-brand-purple focus-visible:ring-offset-2" phx-click="close_display_users_modal">
              <svg class="fill-brand-gray-800 group-hover:fill-white" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="32" height="32"><path d="M12.0007 10.5865L16.9504 5.63672L18.3646 7.05093L13.4149 12.0007L18.3646 16.9504L16.9504 18.3646L12.0007 13.4149L7.05093 18.3646L5.63672 16.9504L10.5865 12.0007L5.63672 7.05093L7.05093 5.63672L12.0007 10.5865Z"></path></svg>
            </button>
          </div>
          <ol>
            <%= Enum.map(assigns[:users], fn {_pid, {_ref, user}} -> %>
              <li><%= user.first_name %> <%= user.last_name %></li>
            <% end) %>
          </ol>
        </div>
      <% end %>
    </div>
    """
  end

  def render(%{sidebar: true} = assigns) do
    ~H"""
    <div class="flex items-center gap-x-2">
      <svg
        class="w-4 h-4 fill-brand-gray-500 group-hover:fill-brand-purple"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        width="16"
        height="16"
      >
        <path d="M2 22C2 17.5817 5.58172 14 10 14C14.4183 14 18 17.5817 18 22H16C16 18.6863 13.3137 16 10 16C6.68629 16 4 18.6863 4 22H2ZM10 13C6.685 13 4 10.315 4 7C4 3.685 6.685 1 10 1C13.315 1 16 3.685 16 7C16 10.315 13.315 13 10 13ZM10 11C12.21 11 14 9.21 14 7C14 4.79 12.21 3 10 3C7.79 3 6 4.79 6 7C6 9.21 7.79 11 10 11ZM18.2837 14.7028C21.0644 15.9561 23 18.752 23 22H21C21 19.564 19.5483 17.4671 17.4628 16.5271L18.2837 14.7028ZM17.5962 3.41321C19.5944 4.23703 21 6.20361 21 8.5C21 11.3702 18.8042 13.7252 16 13.9776V11.9646C17.6967 11.7222 19 10.264 19 8.5C19 7.11935 18.2016 5.92603 17.041 5.35635L17.5962 3.41321Z">
        </path>
      </svg>
      <span class="leading-5 text-brand-gray-600 group-hover:text-brand-purple">
        <%= assigns[:count] %>
      </span>
    </div>
    """
  end

  def preload(list_of_assigns) do
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
