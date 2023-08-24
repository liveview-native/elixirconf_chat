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

    {:ok,
     assign(socket,
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
  def render(
        %{native: %{platform_config: %{user_interface_idiom: ui_idiom}}, platform_id: :swiftui} =
          assigns
      )
      when ui_idiom in ~w(mac pad) do
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
    <div class="px-4">
      <.logo />
      <div class="mx-auto w-full max-w-[1200px] md:grid md:grid-cols-6 border border-brand-gray-200 rounded-t-[32px]">
        <div class="md:col-span-3 md:border-r md:border-brand-gray-200 lg:col-span-2 p-4 min-[448px]:p-6">
          <h1 class="font-medium text-2xl min-[448px]:text-3.5xl text-brand-gray-700">Schedule</h1>
          <.hallway {assigns} />
          <.rooms_list {assigns} />
        </div>
        <div class="md:col-span-3 lg:col-span-4">
          <%= if @room_page do %>
            <.room_page {assigns} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("join_room", %{"room-id" => room_id}, socket) do
    IO.inspect(room_id, label: "CLICK JOIN ROOM" <> room_id)
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
    IO.inspect(body, label: "BODY")

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
      %Room{messages: messages, server_state: %{messages: unsaved_messages}} = room ->
        messages = messages ++ unsaved_messages
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

  def logo(assigns) do
    ~H"""
    <img class="my-5 min-[448px]:mt-8 min-[448px]:mb-7 mx-auto h-10 w-auto" src="/images/elixir-logo.png" width="75" height="60" alt="" />
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
        <LiveSubmitButton modclass="button-style-bordered-prominent tint:elixirpurple" after-submit="clear">
          <Image system-name="paperplane.fill" />
        </LiveSubmitButton>
        <Spacer modclass="h-16 w-32" />
      </HStack>
    </LiveForm>
    """
  end

  def chat_input(assigns) do
    ~H"""
    <form id="chat" phx-submit="post_message">
      <div class="background:rect">
        <input type="text" name="body" class="ph-24" placeholder="Enter Message..." />
        <button type="submit" class="button-style-bordered-prominent tint:elixirpurple">
          Submit <img system-name="paperplane.fill" />
        </button>
        <br class="h-16 w-32" />
      </div>
    </form>
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
          <VStack>
            <ScrollView modclass="refreshable:refresh">
              <%= for {message, index} <- Enum.with_index(@messages) do %>
                <.chat_message
                  current_user_id={@current_user.id}
                  index={index}
                  message={message}
                  native={@native}
                  platform_id={:swiftui}
                />
              <% end %>
            </ScrollView>
          </VStack>
          <Spacer />
        <% end %>
      <% end %>
    </VStack>
    """
  end

  def chat_history(assigns) do
    ~H"""
    <div>
      <div class="font-weight-semibold fg-color:elixirpurple ph-24">
        <img system-name="arrow.left" />
        <p phx-click="leave_room">
          Go Back
        </p>
        <br />
        <.logo height={48} width={48} />
      </div>
      <%= if @loading_room do %>
        <br />
        <div>
          <br />
          <div id="loading-room" />
          <br />
        </div>
        <br />
      <% else %>
        <%= if @messages == [] do %>
          <div>
            <br />
            <div>
              <div modifiers={background(alignment: :center, content: :hero_emoji)}>
                <span class="w-60 h-60 fg-color:lightchrome opacity-0.325" template={:hero_emoji} />
                <p class="type-size-accessibility-2">👋</p>
              </div>
            </div>
            <br class="h-24" />
            <p class="w-375 align-center">
              No Messages in this room. Be the first one to send a message.
            </p>
            <br />
          </div>
        <% else %>
          <br />
          <div>
            <div class="refreshable:refresh">
              <%= for {message, index} <- Enum.with_index(@messages) do %>
                <.chat_message current_user_id={@current_user.id} index={index} message={message} />
              <% end %>
            </div>
          </div>
          <br />
        <% end %>
      <% end %>
    </div>
    """
  end

  def chat_message(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack id={"message_#{@index}"}>
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

  def chat_message(assigns) do
    ~H"""
    <div id={"message_#{@index}"}>
      <%= if @message.user_id == @current_user_id do %>
        <br />
      <% end %>
      <div class="background:rect ph-10 pv-2">
        <%= if @message.user_id == @current_user_id do %>
          <div class="fg-color:elixirpurple" template={:rect} corner-radius="16" />
        <% else %>
          <div class="fg-color:lightchrome opacity-0.25" template={:rect} corner-radius="16" />
        <% end %>
        <div class="p-12 align-leading">
          <%= if @message.user_id == @current_user_id do %>
            <div spacing={8} alignment="leading" class="fg-color-white">
              <div class="capitalize type-size-x-small">
                <p>You</p>
                <br class="w-32" />
                <p><%= Utils.time_formatted(@message.posted_at) %></p>
              </div>
              <p><%= @message.body %></p>
            </div>
          <% else %>
            <div spacing={8} alignment="leading">
              <div class="capitalize type-size-x-small">
                <p><%= @message.posted_by %></p>
                <br class="w-32" />
                <p><%= Utils.time_formatted(@message.posted_at) %></p>
              </div>
              <p><%= @message.body %></p>
            </div>
          <% end %>
        </div>
      </div>
      <%= if @message.user_id != @current_user_id do %>
        <br />
      <% end %>
    </div>
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

  def hallway(assigns) do
    ~H"""
    <%= for timeslot <- @schedule.pinned do %>
      <%= for room <- timeslot.rooms do %>
        <.hallway_item room={room} />
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

  def hallway_item(assigns) do
    ~H"""
    <article class="mt-5 p-3 bg-brand-gray-50 rounded-2xl">
      <div spacing={0} phx-click="join_room" phx-value-room-id={"#{@room.id}"}>
        <h2 class="uppercase font-semibold text-sm text-brand-gray-700 tracking-[3px] text-center">
          <%= @room.title %>
        </h2>
      </div>
    </article>
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

  def rooms_list(assigns) do
    ~H"""
    <%= for {day, timeslots} <- @sorted_days do %>
      <div>
        <section class="mt-6" aria-labelledby="schedule-day">
          <h2 class="text-xl min-[448px]:text-2xl text-brand-gray-800" id="schedule-day"><%= day %></h2>
          <div class="mt-3 space-y-3">
            <%= for timeslot <- timeslots do %>
              <.timeslot_item timeslot={timeslot} track_labels={@track_labels} />
            <% end %>
          </div>
        </section>
      </div>
    <% end %>
    """
  end

  def room_page(
        %{native: %{platform_config: %{user_interface_idiom: ui_idiom}}, platform_id: :swiftui} =
          assigns
      )
      when ui_idiom in ~w(mac pad) do
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

  def room_page(assigns) do
    ~H"""
    <div template={:room_page}>
      <.chat_history {assigns} />
      <.chat_input {assigns} />
    </div>
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

  def timeslot_item(assigns) do
    ~H"""
    <article class="p-3 bg-brand-gray-50 rounded-2xl">
      <div>
        <h3 class="mb-3 uppercase font-semibold text-sm text-brand-gray-700 tracking-[3px]">
          <%= @timeslot.formatted_string %>
        </h3>
        <%= for room <- @timeslot.rooms do %>
          <div>
            <%= if room.track > 0 do %>
              <span class="inline-block mb-2 px-3 py-1.5 rounded-lg border border-brand-gray-300 font-semibold text-brand-gray-500 text-xs uppercase tracking-[3px]">
                Track <%= Map.get(@track_labels, room.track, "?") %>
              </span>
            <% end %>
            <div class="cursor-pointer" phx-click="join_room" phx-value-room-id={"#{room.id}"}>
              <%= if room.presenters != [] do %>
                <div class="flex gap-x-2 items-start">
                  <div class="shrink-0 h-10 w-10 flex items-center justify-center rounded-full bg-white">
                    <svg class="fill-brand-purple" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="32" height="32"><path d="M4 22C4 17.5817 7.58172 14 12 14C16.4183 14 20 17.5817 20 22H18C18 18.6863 15.3137 16 12 16C8.68629 16 6 18.6863 6 22H4ZM12 13C8.685 13 6 10.315 6 7C6 3.685 8.685 1 12 1C15.315 1 18 3.685 18 7C18 10.315 15.315 13 12 13ZM12 11C14.21 11 16 9.21 16 7C16 4.79 14.21 3 12 3C9.79 3 8 4.79 8 7C8 9.21 9.79 11 12 11Z"></path></svg>
                  </div>
                  <div class="grow">
                    <p class="font-medium text-xl/6 text-brand-gray-800"><%= room.title %></p>
                    <div class="mt-1 mb-4 flex items-center justify-between">
                      <p class="leading-5 text-brand-gray-600">
                        <%= Enum.join(room.presenters, ", ") %>
                      </p>
                      <div class="flex items-center gap-x-2">
                        <svg class="w-4 h-4 fill-brand-gray-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path d="M2 22C2 17.5817 5.58172 14 10 14C14.4183 14 18 17.5817 18 22H16C16 18.6863 13.3137 16 10 16C6.68629 16 4 18.6863 4 22H2ZM10 13C6.685 13 4 10.315 4 7C4 3.685 6.685 1 10 1C13.315 1 16 3.685 16 7C16 10.315 13.315 13 10 13ZM10 11C12.21 11 14 9.21 14 7C14 4.79 12.21 3 10 3C7.79 3 6 4.79 6 7C6 9.21 7.79 11 10 11ZM18.2837 14.7028C21.0644 15.9561 23 18.752 23 22H21C21 19.564 19.5483 17.4671 17.4628 16.5271L18.2837 14.7028ZM17.5962 3.41321C19.5944 4.23703 21 6.20361 21 8.5C21 11.3702 18.8042 13.7252 16 13.9776V11.9646C17.6967 11.7222 19 10.264 19 8.5C19 7.11935 18.2016 5.92603 17.041 5.35635L17.5962 3.41321Z"></path></svg>
                        <p class="leading-5 text-brand-gray-600">0</p>
                      </div>
                    </div>
                  </div>
                </div>
              <% else %>
                <p class="font-medium text-xl/6 text-brand-gray-800"><%= room.title %></p>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </article>
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
