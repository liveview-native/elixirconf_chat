defmodule ElixirconfChatWeb.AuthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  alias ElixirconfChat.Users

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
      <%= if assigns[:success] do %>
        <VStack>
          <Text id="success-message">Success! Check your email for magic link</Text>
        </VStack>
      <% else %>
        <VStack>
          <LiveForm id="login" phx-submit="login">
            <TextField name="email" modifiers={frame(height: 48) |> text_input_autocapitalization(autocapitalization: :never)}>
              Email
            </TextField>
            <LiveSubmitButton modifiers={button_style(style: :bordered_prominent) |> tint(color: "#6558f5")}>
              <Text>Enter</Text>
            </LiveSubmitButton>
            <%= if assigns[:error] do %>
              <Text modifiers={foreground_style({:color, :red})}>
                <%= @error %>
              </Text>
            <% end %>
          </LiveForm>
        </VStack>
      <% end %>
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
  def handle_event("login", %{"email" => email}, socket) do
    case Users.get_user_by_email(email) do
      nil ->
        {:noreply, assign(socket, error: no_user_error(), success: false)}

      user ->
        {:noreply, assign(socket, error: nil, success: true)}
    end
  end

  ###

  defp welcome_heading, do: "Welcome to ElixirConf 2023 Chat!"

  defp welcome_message, do: "Enter your email you used to register to get started"

  defp no_user_error,
    do: "There was no user associated. Try again or contact the conference staff."
end
