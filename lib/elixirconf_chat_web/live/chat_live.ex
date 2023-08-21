defmodule ElixirconfChatWeb.ChatLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  alias ElixirconfChat.Chat
  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Utils

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  on_mount ElixirconfChatWeb.AssignUser

  @impl true
  def mount(_params, _session, socket) do
    schedule = Chat.schedule()

    {:ok, assign(socket,
      loading_room: false,
      messages: [],
      room_id: nil,
      room_page: false,
      room: nil,
      schedule: schedule,
      sorted_days: sorted_days(schedule),
      track_labels: %{1 => "A", 2 => "B", 3 => "C"}
    )}
  end

  @impl true
  def render(%{native: %{platform_config: %{user_interface_idiom: ui_idiom}}, platform_id: :swiftui} = assigns) when ui_idiom in ~w(mac pad) do
    ~SWIFTUI"""
    <VStack modclass="w-full">
      <HStack>
        <.logo height={48} width={48} native={@native} platform_id={:swiftui} />
      </HStack>
      <HStack>
        <VStack modclass="w-400">
          <HStack>
            <Text modclass="font-title font-weight-semibold h-48 ph-24">Schedule</Text>
          </HStack>
          <.hallway {assigns} />
          <.rooms_list {assigns} />
        </VStack>
        <Spacer />
        <VStack>
          <%= if @room_page do %>
            <.room_page {assigns} />
          <% end %>
          <Spacer modclass="h-24" />
        </VStack>
      </HStack>
    </VStack>
    """
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

    {:noreply, assign(socket, loading_room: true, room_page: true)}
  end

  @impl true
  def handle_event("leave_room", _assigns, socket) do
    room_id = Map.get(socket.assigns, :room_id)

    if room_id do
      Chat.leave_room(room_id, self())
    end

    {:noreply, assign(socket, messages: [], room: nil, room_id: nil, room_page: false)}
  end

  @impl true
  def handle_event("post_message", %{"body" => body}, socket) do
    case socket.assigns do
      %{room: %{id: room_id}} ->
        Chat.post_message(room_id, %{
          body: body,
          posted_at: Utils.server_time() |> DateTime.to_naive(),
          from: self(),
          room_id: room_id,
          user_id: socket.assigns.current_user.id
        })
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, socket}
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

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="pv-12">
      <Image modclass="stretch w-52 h-52" name="Logo" />
    </VStack>
    """
  end

  def chat_input(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="chat" phx-submit="post_message">
      <HStack modclass="background:rect">
        <RoundedRectangle modclass="stroke:lightchrome h-60 p-16 fg-color-secondary opacity-0.5" template={:rect} corner-radius="8" />
        <TextField name="body" modclass="ph-24">
          Enter Message...
        </TextField>
        <LiveSubmitButton modclass="button-style-bordered-prominent tint:elixirpurple">
          <Image system-name="paperplane.fill" />
        </LiveSubmitButton>
        <Spacer modclass="h-16 w-32" />
      </HStack>
    </LiveForm>
    """
  end

  def chat_history(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <ZStack modclass="font-weight-semibold fg-color:elixirpurple ph-24">
        <%= if @native.platform_config.user_interface_idiom == "phone" do %>
          <HStack>
            <HStack>
              <Image system-name="arrow.left" />
                <Text phx-click="leave_room">
                  Go Back
                </Text>
            </HStack>
            <Spacer />
          </HStack>
          <.logo height={48} width={48} native={@native} platform_id={:swiftui} />
        <% end %>
      </ZStack>
      <%= if @loading_room do %>
        <Spacer />
        <HStack>
          <Spacer />
            <ProgressView id="loading-room" />
          <Spacer />
        </HStack>
        <Spacer />
      <% else %>
        <%= if @messages == [] do %>
          <VStack>
            <Spacer />
            <HStack>
              <ZStack modifiers={background(alignment: :center, content: :hero_emoji)}>
                <Circle modclass="w-60 h-60 fg-color:lightchrome opacity-0.325" template={:hero_emoji} />
                <Text modclass="type-size-accessibility-2">👋</Text>
              </ZStack>
            </HStack>
            <Spacer modclass="h-24" />
            <Text modclass="w-375 align-center">
              No Messages in this room. Be the first one to send a message.
            </Text>
            <Spacer />
          </VStack>
        <% else %>
          <Spacer />
          <ScrollView modclass="refreshable:refresh">
            <%= for message <- @messages do %>
              <.chat_message
                current_user_id={@current_user.id}
                message={message}
                native={@native}
                platform_id={:swiftui}
              />
            <% end %>
          </ScrollView>
          <Spacer />
        <% end %>
      <% end %>
    </VStack>
    """
  end

  def chat_message(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack>
      <%= if @message.user_id == @current_user_id do %>
        <Spacer />
      <% end %>
      <VStack modclass="background:rect ph-10 pv-2">
        <%= if @message.user_id == @current_user_id do %>
          <RoundedRectangle modclass="fg-color:elixirpurple" template={:rect} corner-radius="16" />
        <% else %>
          <RoundedRectangle modclass="fg-color:lightchrome opacity-0.25" template={:rect} corner-radius="16" />
        <% end %>
        <HStack modclass="p-12 align-leading">
          <%= if @message.user_id == @current_user_id do %>
            <VStack spacing={8} alignment="leading" modclass="fg-color-white">
              <HStack modclass="capitalize type-size-x-small">
                <Text>You</Text>
                <Spacer modclass="w-32" />
                <Text><%= Utils.time_formatted(@message.posted_at) %></Text>
              </HStack>
              <Text><%= @message.body %></Text>
            </VStack>
          <% else %>
            <VStack spacing={8} alignment="leading">
              <HStack modclass="capitalize type-size-x-small">
                <Text><%= @message.posted_by %></Text>
                <Spacer modclass="w-32" />
                <Text><%= Utils.time_formatted(@message.posted_at) %></Text>
              </HStack>
              <Text><%= @message.body %></Text>
            </VStack>
          <% end %>
        </HStack>
      </VStack>
      <%= if @message.user_id != @current_user_id do %>
        <Spacer />
      <% end %>
    </HStack>
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
    <VStack modclass="background:rect ph-24">
      <RoundedRectangle modclass="fg-color:lightchrome opacity-0.25" template={:rect} corner-radius="16" />
      <HStack spacing={0} phx-click="join_room" phx-value-room-id={"#{@room.id}"}>
        <Spacer />
        <Circle modclass="h-10 w-10 p-10 fg-color:forestgreen" />
        <Text modclass="font-subheadline font-weight-semibold h-48 capitalize kerning-3">
          <%= @room.title %>
        </Text>
        <Spacer />
      </HStack>
    </VStack>
    """
  end

  def rooms_list(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView>
      <%= for {day, timeslots} <- @sorted_days do %>
        <LazyVStack pinned-views="section-headers">
          <Section>
            <VStack template={:content}>
              <%= for timeslot <- timeslots do %>
                <.timeslot_item
                  timeslot={timeslot}
                  native={@native}
                  platform_id={:swiftui}
                  track_labels={@track_labels} />
              <% end %>
            </VStack>
            <HStack modclass="background:rect" template={:header}>
              <Rectangle modclass="fg-color:bgcolor" template={:rect} />
              <Text modclass="font-title h-48 ph-24"><%= day %></Text>
              <Spacer />
            </HStack>
          </Section>
        </LazyVStack>
      <% end %>
    </ScrollView>
    """
  end

  def room_page(%{native: %{platform_config: %{user_interface_idiom: ui_idiom}}, platform_id: :swiftui} = assigns) when ui_idiom in ~w(mac pad) do
    ~SWIFTUI"""
    <VStack>
      <.chat_history {assigns} />
      <.chat_input {assigns} />
    </VStack>
    """
  end

  def room_page(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="full-screen-cover:room-page">
      <VStack template={:room_page}>
        <Spacer />
        <.chat_history {assigns} />
        <.chat_input {assigns} />
      </VStack>
    </VStack>
    """
  end

  def timeslot_item(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modclass="background:rect ph-24 align-leading image-scale-small">
      <RoundedRectangle modclass="fg-color:lightchrome opacity-0.25" template={:rect} corner-radius="16" />
      <VStack spacing={16} modclass="p-16">
        <HStack>
          <Text modclass="font-subheadline type-size-x-small font-weight-semibold h-12 capitalize kerning-2 opacity-0.825">
            <%= @timeslot.formatted_string %>
          </Text>
          <Spacer />
        </HStack>
        <%= for room <- @timeslot.rooms do %>
          <VStack>
            <HStack>
              <%= if room.track > 0 do %>
                <HStack modclass="fg-color-secondary h-24 opacity-0.75 overlay:rect">
                  <RoundedRectangle modclass="stroke-secondary fg-color-clear" template={:rect} corner-radius="8" />
                  <Text modclass="capitalize p-8 kerning-4 font-subheadline type-size-x-small font-weight-semibold offset-x-2">Track <%= Map.get(@track_labels, room.track, "?") %></Text>
                </HStack>
                <Spacer />
              <% end %>
            </HStack>
            <HStack phx-click="join_room" phx-value-room-id={"#{room.id}"} spacing={8}>
              <VStack spacing={8}>
                <HStack>
                  <Text modclass="font-headline font-weight-semibold"><%= room.title %></Text>
                  <Spacer />
                </HStack>
                <%= if room.presenters != [] do %>
                  <HStack>
                    <Text modclass="font-subheadline opacity-0.825"><%= Enum.join(room.presenters, ", ") %></Text>
                    <Spacer />
                  </HStack>
                <% end %>
              </VStack>
              <HStack modclass="opacity-0.75 type-size-x-small">
                <Image system-name="person.2" />
                <Text>0</Text>
              </HStack>
            </HStack>
          </VStack>
        <% end %>
      </VStack>
    </VStack>
    """
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
