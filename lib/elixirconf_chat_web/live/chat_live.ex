defmodule ElixirconfChatWeb.ChatLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  alias ElixirconfChat.Chat
  alias ElixirconfChat.Chat.Room

  import ElixirconfChatWeb.SharedComponents, only: [logo: 1]

  on_mount ElixirconfChatWeb.LiveSession

  native_binding :show_room_page, :boolean, default: false

  @impl true
  def mount(_params, _session, socket) do
    schedule = Chat.schedule()

    {:ok, assign(socket,
      loading_room: false,
      messages: [],
      room_id: nil,
      room: nil,
      schedule: schedule,
      show_room_page: false,
      sorted_days: sorted_days(schedule),
      track_labels: %{1 => "A", 2 => "B", 3 => "C"}
    )}
  end

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="w-full">
      <.room_page {assigns} />
      <HStack>
        <.logo height={48} width={48} native={@native} platform_id={:swiftui} />
      </HStack>
      <.hallway {assigns} />
      <.rooms_list {assigns} />
    </VStack>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      TODO: Build this
    </div>
    """
  end

  @impl true
  def handle_event("join_room", %{"room-id" => room_id}, socket) do
    # Load Room asynchronously
    Process.send_after(self(), {:get_room, room_id}, 10)
    Chat.join_room(room_id, self())

    socket =
      socket
      |> assign(loading_room: true)
      |> assign_native_bindings(show_room_page: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("leave_room", _assigns, socket) do
    room_id = Map.get(socket.assigns, :room_id)

    if room_id do
      Chat.leave_room(room_id, self())
    end

    socket =
      socket
      |> assign(messages: [], room: nil, room_id: nil)
      |> assign_native_bindings(show_room_page: false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("post_message", %{"body" => body}, socket) do
    case socket.assigns do
      %{current_user: %{id: user_id}, room: %{id: room_id}} ->
        Chat.post_message(room_id, %{
          body: body,
          from: self(),
          room_id: room_id,
          user_id: user_id
        })
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:get_room, room_id}, socket) do
    case Chat.get_room(room_id) do
      %Room{server_state: %{messages: messages}} = room ->
        {:noreply, assign(socket, loading_room: false, messages: messages, room: room)}

      _ ->
        # TODO: Handle error
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_message, new_message}, socket) do
    messages = socket.assigns.messages
    updated_messages = messages ++ [new_message]

    {:noreply, assign(socket, messages: updated_messages)}
  end

  def chat_history(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <HStack modifiers={padding(edges: :horizontal, length: 24)}>
        <Text phx-click="leave_room">Go Back</Text>
        <Spacer />
        <.logo height={48} width={48} native={@native} platform_id={:swiftui} />
        <Spacer />
        <Spacer />
      </HStack>
      <%= if @loading_room do %>
        <ProgressView />
      <% else %>
        <%= if @messages == [] do %>
          <VStack>
            <Spacer />
            <HStack>
              <ZStack modifiers={background(alignment: :center, content: :hero_emoji)}>
                <Circle modclass="hero-emoji-container" template={:hero_emoji} />
                <Text modclass="hero-emoji">👋</Text>
              </ZStack>
            </HStack>
            <Spacer modifiers={frame(height: 24, width: :infinity)} />
            <Text modclass="no-messages-text">
              No Messages in this room. Be the first one to send a message.
            </Text>
            <Spacer />
          </VStack>
        <% else %>
          <VStack>
            <ScrollView>
              <%= for message <- @messages do %>
                <.chat_message message={message} native={@native} platform_id={:swiftui} />
              <% end %>
            </ScrollView>
          </VStack>
        <% end %>
      <% end %>
    </VStack>
    """
  end

  def chat_input(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="chat" phx-submit="post_message">
      <HStack modifiers={background(alignment: :center, content: :chat_input_background)}>
        <RoundedRectangle modclass="chat-input-background" template={:chat_input_background} corner-radius="8" />
        <TextField name="body" modclass="chat-input">
          Enter Message...
        </TextField>
        <LiveSubmitButton modifiers={button_style(style: :bordered_prominent) |> tint(color: "#6558f5")}>
          <Image system-name="paperplane.fill" />
        </LiveSubmitButton>
        <Spacer modifiers={frame(height: 16, width: 32)} />
      </HStack>
    </LiveForm>
    """
  end

  def chat_message(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="chat-message">
      <RoundedRectangle modclass="chat-message-item" template={:bg_content} corner-radius="16" />
      <HStack modclass="w-full">
        <Text modclass="chat-message-body"><%= @message.body %></Text>
      </HStack>
    </VStack>
    """
  end

  def hallway(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <%= for timeslot <- @schedule.pinned do %>
      <%= for room <- timeslot.rooms do %>
        <.hallway_item room={room} native={@native} platform_id={:swiftui} />
      <% end %>
    <% end %>
    """
  end

  def hallway_item(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="hallway">
      <RoundedRectangle modclass="hallway-item" template={:bg_content} corner-radius="16" />
      <HStack modclass="w-full" spacing={0.0} phx-click="join_room" phx-value-room-id={"#{@room.id}"}>
        <Spacer />
        <Circle modclass="dot-#049372" />
        <Text modclass="hallway-title"><%= @room.title %></Text>
        <Spacer />
      </HStack>
    </VStack>
    """
  end

  def rooms_list(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView modclass="w-full">
      <%= for {day, timeslots} <- @sorted_days do %>
        <VStack modclass="w-full" pinnedViews="sectionHeaders">
          <Section modclass="w-full">
            <VStack modclass="w-full" template={:content}>
              <%= for timeslot <- timeslots do %>
                <.timeslot_item
                  timeslot={timeslot}
                  native={@native}
                  platform_id={:swiftui}
                  track_labels={@track_labels} />
              <% end %>
            </VStack>
            <HStack modclass="w-full" template={:header}>
              <Text modclass="day-heading"><%= day %></Text>
            </HStack>
          </Section>
        </VStack>
      <% end %>
    </ScrollView>
    """
  end

  def room_page(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="room-page">
      <VStack template={:room_content}>
        <Spacer />
        <.chat_history {assigns} />
        <.chat_input {assigns} />
      </VStack>
    </VStack>
    """
  end

  def timeslot_item(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="timeslot">
      <RoundedRectangle modclass="timeslot-item" template={:bg_content} corner-radius="16" />
      <VStack>
        <HStack>
          <Text modclass="time-range"><%= @timeslot.formatted_string %></Text>
          <Spacer />
        </HStack>
        <%= for room <- @timeslot.rooms do %>
          <VStack modclass="room" alignment="trailing">
            <HStack>
              <%= if room.track > 0 do %>
                <ZStack modclass="track">
                  <Text>Track <%= Map.get(@track_labels, room.track, "?") %></Text>
                </ZStack>
                <Spacer />
              <% end %>
            </HStack>
            <HStack modclass="room-link" phx-click="join_room" phx-value-room-id={"#{room.id}"}>
              <VStack>
                <Text modclass="room-title w-full"><%= room.title %></Text>
                <%= if room.presenters != [] do %>
                  <Text modclass="room-presenter w-full"><%= Enum.join(room.presenters, ", ") %></Text>
                <% end %>
              </VStack>
              <HStack>
                <Image modclass="users-icon" system-name="person.2" />
                <Text modclass="users-count">0</Text>
              </HStack>
            </HStack>
          </VStack>
        <% end %>
      </VStack>
    </VStack>
    """
  end

  def modclass(native, "hallway") do
    native
    |> background(alignment: :center, content: :bg_content)
    |> padding(edges: :horizontal, length: 10)
  end

  def modclass(native, "hallway-item") do
    native
    |> foreground_color(:secondary)
    |> opacity(0.15)
  end

  def modclass(native, "chat-message") do
    native
    |> background(alignment: :center, content: :bg_content)
    |> padding(edges: :horizontal, length: 10)
    |> padding(edges: :vertical, length: 2)
  end

  def modclass(native, "chat-message-item") do
    native
    |> foreground_color(:secondary)
    |> opacity(0.15)
  end

  def modclass(native, "timeslot") do
    native
    |> padding(edges: :all, length: 16)
    |> background(alignment: :center, content: :bg_content)
    |> padding(edges: :horizontal, length: 10)
    |> padding(edges: :vertical, length: 2)
    |> multiline_text_alignment(:leading)
  end

  def modclass(native, "timeslot-item") do
    native
    |> foreground_color(:secondary)
    |> opacity(0.15)
  end

  def modclass(native, "track") do
    native
    |> foreground_color(:secondary)
    |> frame(height: 24)
    |> opacity(0.75)
  end

  def modclass(native, "hallway-title") do
    native
    |> font(font: {:system, :subheadline})
    |> font_weight(:semibold)
    |> frame(height: 48)
    |> text_case(:uppercase)
    |> kerning(2.5)
  end

  def modclass(native, "room") do
    native
    |> padding(edges: :vertical, length: 1)
  end

  def modclass(native, "room-link") do
    native
    |> button_style(:plain)
    |> font(font: {:system, :body})
    |> frame(max_width: :infinity, alignment: :leading)
    |> multiline_text_alignment(:leading)
  end

  def modclass(native, "hallway-link") do
    native
    |> button_style(:plain)
    |> font(font: {:system, :body})
    |> frame(max_width: :infinity, alignment: :center)
    |> multiline_text_alignment(:center)
  end

  def modclass(native, "room-page") do
    native
    |> full_screen_cover(content: :room_content, is_presented: :show_room_page)
  end

  def modclass(native, "room-title") do
    native
    |> font(font: {:system, :headline})
    |> font_weight(:semibold)
    |> frame(max_width: :infinity, alignment: :leading)
    |> padding(edges: :vertical, length: 0.5)
  end

  def modclass(native, "room-presenter") do
    native
    |> font(font: {:system, :subheadline})
    |> frame(max_width: :infinity, alignment: :leading)
    |> opacity(0.825)
  end

  def modclass(native, "w-full") do
    native
    |> frame(width: :infinity, max_width: 400, alignment: :leading)
  end

  def modclass(native, "users-icon") do
    native
    |> image_scale(:small)
    |> opacity(0.75)
  end

  def modclass(native, "users-count") do
    native
    |> dynamic_type_size(:small)
    |> opacity(0.75)
  end

  def modclass(native, "day-heading") do
    native
    |> font(font: {:system, :title})
    |> font_weight(:light)
    |> frame(height: 48, width: :infinity, max_width: 400, alignment: :leading)
    |> padding(edges: :horizontal, length: 16)
  end

  def modclass(native, "dot-" <> color) do
    native
    |> foreground_color(color)
    |> frame(height: 10, width: 10)
    |> padding(edges: :horizontal, length: 10)
  end

  def modclass(native, "time-range") do
    native
    |> font(font: {:system, :subheadline})
    |> dynamic_type_size(:x_small)
    |> font_weight(:semibold)
    |> frame(height: 12)
    |> text_case(:uppercase)
    |> kerning(2.5)
    |> opacity(0.925)
  end

  def modclass(native, "no-messages-text") do
    native
    |> frame(width: :infinity, max_width: 375, alignment: :center)
    |> multiline_text_alignment(:center)
  end

  def modclass(native, "hero-emoji") do
    native
    |> dynamic_type_size(:accessibility_2)
  end

  def modclass(native, "hero-emoji-container") do
    native
    |> frame(width: 60, height: 60)
    |> foreground_style({:color, :secondary})
    |> opacity(0.25)
  end

  def modclass(native, "chat-input") do
    native
    |> padding(edges: :horizontal, length: 24)
  end

  def modclass(native, "chat-input-background") do
    native
    |> stroke(content: {:color, :secondary}, style: [line_width: 1])
    |> frame(width: :infinity, height: 60)
    |> padding(edges: :all, length: 16)
    |> foreground_style({:color, :secondary})
    |> opacity(0.25)
  end

  def modclass(native, "chat-message-body") do
    native
    |> padding(edges: :all, length: 16)
  end

  ###

  @days_of_week %{
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday",
    7 => "Sunday"
  }
  defp sorted_days(%{} = schedule) do
    schedule
    |> Enum.filter(fn {key, _timeslots} -> key != :pinned end)
    # |> Enum.sort(fn {time_a, _timeslots_a}, {time_b, _timeslots_a} -> time_a > time_b end)
    |> Enum.map(fn {time, timeslots} ->
      day_of_week = Date.day_of_week(time)
      day_of_week_formatted = @days_of_week[day_of_week]

      {day_of_week_formatted, timeslots}
    end)
  end
end
