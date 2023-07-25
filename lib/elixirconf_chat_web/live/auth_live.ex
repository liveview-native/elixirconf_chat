defmodule ElixirconfChatWeb.AuthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modifiers={multiline_text_alignment(alignment: :center) |> text_field_style(style: :rounded_border)}}>
      <Spacer />
      <Image modifiers={resizable(resizing_mode: :stretch) |> frame(height: 256, width: 256)} name="Logo" />
      <Text><%= welcome_heading() %></Text>
      <Spacer modifiers={frame(height: 8)} />
      <HStack modifiers={multiline_text_alignment(alignment: :center)}>
        <Spacer />
        <Text><%= welcome_message() %></Text>
        <Spacer />
      </HStack>
      <VStack>
        <LiveForm id="login" phx-submit="login">
          <HStack>
            <Spacer modifiers={frame(width: 16)} />
            <TextField name="email" modifiers={frame(height: 48)}>
              Email
            </TextField>
            <Spacer modifiers={frame(width: 16)} />
          </HStack>
          <Spacer modifiers={frame(height: 16)} />
          <HStack modifiers={multiline_text_alignment(alignment: :trailing)}>
            <LiveSubmitButton>
              <Text modifiers={
                background(content: :text_bg)
                |> foreground_style({:color, :white})
              }>
                Enter
                <RoundedRectangle
                  template={:text_bg}
                  corner-radius="8"
                  modifiers={
                    frame(width: 92, height: 48)
                    |> foreground_style({:color, "#6558f5"})
                  } />
              </Text>
            </LiveSubmitButton>
          </HStack>
        </LiveForm>
      </VStack>
      <Spacer />
    </VStack>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= welcome_heading() %></h1>
      <p><%= welcome_message() %></p>
      <input name="email" />
      <button phx-click="submit" type="button">
        <div>Enter</div>
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("login", %{"email" => _email}, socket) do
    {:noreply, socket}
  end

  ###

  defp welcome_heading, do: "Welcome to ElixirConf 2023 Chat!"
  defp welcome_message, do: "Enter your email you used to register to get started"
end
