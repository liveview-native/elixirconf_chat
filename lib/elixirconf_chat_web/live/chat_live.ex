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
      <div class="mx-auto w-full max-w-[1200px] md:grid md:grid-cols-12 border border-brand-gray-200 rounded-t-[32px]">
        <div class="h-[calc(33vh-5rem)] md:h-[calc(100vh-6.25rem)] overflow-y-auto border-b border-brand-gray-200 md:col-span-6 md:border-b-0 md:border-r md:border-brand-gray-200 lg:col-span-5 xl:col-span-4 p-4 md:p-6">
          <h1 class="font-medium text-2xl md:text-3.5xl text-brand-gray-700">Schedule</h1>
          <.hallway {assigns} />
          <.rooms_list {assigns} />
        </div>
        <div class="relative h-[calc(67vh-5rem)] md:h-[calc(100vh-6.25rem)] overflow-y-auto md:col-span-6 lg:col-span-7 xl:col-span-8 p-4 md:p-6">
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
    <img class="my-5 md:mt-8 md:mb-7 mx-auto h-10 w-auto" src="/images/elixir-logo.png" width="75" height="60" alt="" />
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
      <div class="px-2 py-[5px] flex items-center justify-between gap-x-2 border border-brand-gray-200 rounded-lg">
        <label class="sr-only" for="chat-input"></label>
        <input class="w-[calc(100%-1rem)] py-2 px-2 text-lg md:text-xl text-brand-gray-400 border-none transition duration-200 focus:rounded-sm focus:ring-2 focus:ring-brand-purple" type="text" name="body" class="ph-24" placeholder="Enter Message..." id="chat-input" />
        <button type="submit" class="w-10 h-10 flex items-center justify-center bg-brand-purple rounded-xl border-2 border-transparent group transition duration-200 hover:bg-white hover:border-brand-purple outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-purple">
          <span class="sr-only">Submit</span>
          <svg class="fill-white group-hover:fill-brand-purple" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path d="M3 13.0001H9V11.0001H3V1.8457C3 1.56956 3.22386 1.3457 3.5 1.3457C3.58425 1.3457 3.66714 1.36699 3.74096 1.4076L22.2034 11.562C22.4454 11.695 22.5337 11.9991 22.4006 12.241C22.3549 12.3241 22.2865 12.3925 22.2034 12.4382L3.74096 22.5925C3.499 22.7256 3.19497 22.6374 3.06189 22.3954C3.02129 22.3216 3 22.2387 3 22.1544V13.0001Z"></path></svg>
        </button>
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
          <div class="space-y-3">
            <div class="space-y-3 refreshable:refresh">
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
      <div class="flex flex-col">
        <%= if @message.user_id == @current_user_id do %>
          <div class="self-end max-w-[292px] p-3 bg-brand-purple text-brand-gray-50 rounded-2xl rounded-br-none">
            <div class="mb-1 flex items-center justify-between gap-x-7 text-[13px]/[18px] text-brand-gray-100 uppercase">
              <p class="font-semibold tracking-[3px]">You</p>
              <p class="font-medium"><%= Utils.time_formatted(@message.posted_at) %></p>
            </div>
            <p class="font-medium"><%= @message.body %></p>
          </div>
        <% else %>
          <div class="self-start max-w-[292px] p-3 bg-brand-gray-50 text-brand-gray-900 rounded-2xl rounded-bl-none">
            <div class="mb-1 flex items-center justify-between gap-x-7 text-[13px]/[18px] uppercase">
              <p class="font-semibold text-brand-gray-500 tracking-[3px]"><%= @message.posted_by %></p>
              <p class="font-medium text-brand-gray-500"><%= Utils.time_formatted(@message.posted_at) %></p>
            </div>
            <p class="font-medium"><%= @message.body %></p>
          </div>
        <% end %>
      </div>
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
    <div class="mt-5 p-3 bg-brand-gray-50 rounded-2xl">
      <div class="text-center">
        <button class="w-full uppercase font-semibold text-sm text-brand-gray-700 tracking-[3px] text-center cursor-pointer hover:text-brand-purple hover:underline outline-none focus-visible:outline-2 focus-visible:outline-offset-[6px] focus-visible:outline-brand-purple focus-visible:rounded-lg" phx-click="join_room" phx-value-room-id={"#{@room.id}"}>
          <!-- TODO: Number of users online in Hallway -->
          <span class="inline-block mr-3 w-2.5 h-2.5 bg-[#049372] rounded-full"></span><%= @room.title %> <span>(0 Online)</span>
        </button>
      </div>
    </div>
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
          <h2 class="text-xl md:text-2xl text-brand-gray-800" id="schedule-day"><%= day %></h2>
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
    <div class="grid grid-rows-[1fr_auto] h-full">
      <div class="h-[calc(100%-5rem)] overflow-y-scroll">
        <.chat_history {assigns} />
      </div>
      <div>
        <.chat_input {assigns} />
      </div>
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
    <div class="p-3 bg-brand-gray-50 rounded-2xl">
      <div>
        <div class="mb-3 flex flex-wrap items-center justify-between uppercase font-semibold text-sm text-brand-gray-700 tracking-[3px]">
          <h3>
            <%= @timeslot.formatted_string %>
          </h3>
          <!-- TODO: Doors open or not -->
          <span>Doors Open</span>
        </div>
        <%= for room <- @timeslot.rooms do %>
          <div>
            <%= if room.track > 0 do %>
              <span class="inline-block mb-2 px-3 py-1.5 rounded-lg border border-brand-gray-300 font-semibold text-brand-gray-500 text-xs uppercase tracking-[3px]">
                Track <%= Map.get(@track_labels, room.track, "?") %>
              </span>
            <% end %>
            <div>
              <div>
                <button class="w-full text-left font-medium text-xl/6 text-brand-gray-800 break-words cursor-pointer hover:text-brand-purple hover:underline outline-none focus-visible:outline-2 focus-visible:outline-offset-[6px] focus-visible:outline-brand-purple focus-visible:rounded-lg" phx-click="join_room" phx-value-room-id={"#{room.id}"}><%= room.title %></button>
                <%= if room.presenters != [] do %>
                  <div class="mt-1 mb-4 flex items-center justify-between">
                    <p class="leading-5 text-brand-gray-600 group-hover:text-brand-purple">
                      <%= Enum.join(room.presenters, ", ") %>
                    </p>
                    <div class="flex items-center gap-x-2">
                      <svg class="w-4 h-4 fill-brand-gray-500 group-hover:fill-brand-purple" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path d="M2 22C2 17.5817 5.58172 14 10 14C14.4183 14 18 17.5817 18 22H16C16 18.6863 13.3137 16 10 16C6.68629 16 4 18.6863 4 22H2ZM10 13C6.685 13 4 10.315 4 7C4 3.685 6.685 1 10 1C13.315 1 16 3.685 16 7C16 10.315 13.315 13 10 13ZM10 11C12.21 11 14 9.21 14 7C14 4.79 12.21 3 10 3C7.79 3 6 4.79 6 7C6 9.21 7.79 11 10 11ZM18.2837 14.7028C21.0644 15.9561 23 18.752 23 22H21C21 19.564 19.5483 17.4671 17.4628 16.5271L18.2837 14.7028ZM17.5962 3.41321C19.5944 4.23703 21 6.20361 21 8.5C21 11.3702 18.8042 13.7252 16 13.9776V11.9646C17.6967 11.7222 19 10.264 19 8.5C19 7.11935 18.2016 5.92603 17.041 5.35635L17.5962 3.41321Z"></path></svg>
                      <!-- TODO: number of users -->
                      <p class="leading-5 text-brand-gray-600 group-hover:text-brand-purple">0</p>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
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
