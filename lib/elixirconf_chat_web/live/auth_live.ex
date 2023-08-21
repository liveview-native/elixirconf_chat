defmodule ElixirconfChatWeb.AuthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  alias ElixirconfChat.Auth
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modifiers={multiline_text_alignment(alignment: :center) |> text_field_style(style: :rounded_border)}}>
      <.logo logo_title={true} {assigns} />
      <Spacer modclass="h-24" />
      <VStack modclass="p-24">
        <%= if assigns[:user] do %>
          <.login_code_form {assigns} />
        <% else %>
          <.email_form {assigns} />
        <% end %>
      </VStack>
      <Spacer />
    </VStack>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <input name="email" />
      <button phx-click="submit" type="button">
        <div>Enter</div>
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("check_email", %{"email" => email}, socket) do
    with {:user, %User{} = user} <- {:user, Users.get_user_by_email(email)},
         {:user_with_code, {:ok, %User{} = user_with_code}} <- {:user_with_code, Auth.randomize_user_login_code(user)}
    do
      {:noreply, assign(socket, error: nil, user: user_with_code)}
    else
      {:user, nil} ->
        {:noreply, assign(socket, error: "There was no user associated. Try again or contact the conference staff.", user: nil)}

      {:user_with_code, _error} ->
        {:noreply, assign(socket, error: "An unexpected error has occurred. Please contact the conference staff for support.", user: nil)}
    end
  end

  @impl true
  def handle_event("verify_code", %{"login_code" => login_code}, socket) do
    with %User{id: user_id, login_code: user_login_code} when is_binary(user_login_code) <- Map.get(socket.assigns, :user),
         {:login_code_valid?, true} <- {:login_code_valid?, login_code == user_login_code},
         token <- Auth.generate_token(user_id)
    do
      {:noreply, push_navigate(socket, to: "/chat?token=#{token}", replace: true)}
    else
      {:login_code_valid?, false} ->
        {:noreply, assign(socket, error: "The code doesn't match")}

      _ ->
        {:noreply, assign(socket, error: "Your login code has expired. Please go back and try again.")}
    end
  end

  ###

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Image modclass="stretch w-82 h-82 offset-y-8" name="Logo" />
      <Text modclass="capitalize type-size-x-small kerning-2 font-weight-semibold">ElixirConf Chat</Text>
    </VStack>
    """
  end

  defp email_form(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="email" phx-submit="check_email">
      <.welcome_message {assigns} />
      <Spacer modclass="h-48" />
      <HStack modclass="align-leading h-32">
        <Text>Your Email Address</Text>
        <Spacer />
      </HStack>
      <TextField name="email" modclass="disable-autocorrect autocapitalize-never h-42 p-8 text-field-plain overlay:rect type-size-x-large align-leading">
        <RoundedRectangle modclass="stroke:lightchrome fg-color-clear" corner-radius="8" template={:rect} />
      </TextField>
      <Spacer modclass="h-32" />
      <LiveSubmitButton modclass="w-full h-56 background:rect">
        <Spacer />
        <Text modclass="fg-color-white font-weight-semibold type-size-x-large">Log In</Text>
        <Spacer />
        <RoundedRectangle modclass="fg-color:elixirpurple" corner-radius="8" template={:rect} />
      </LiveSubmitButton>
      <%= if assigns[:error] do %>
        <Text modifiers={foreground_style({:color, :red})}>
          <%= @error %>
        </Text>
      <% end %>
    </LiveForm>
    """
  end

  defp login_code_form(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="login_code" phx-submit="verify_code">
      <Text modclass="font-title font-weight-semibold p-8">Enter Code to access</Text>
      <Text modclass="line-spacing-8 font-weight-light">
        We’ve sent a unique code to your email address. Please enter it below to continue.
      </Text>
      <Spacer modclass="h-64" />
      <HStack modclass="h-12 offset-y--16 fg-color:errorcolor">
        <%= if assigns[:error] do %>
          <Image system-name="exclamationmark.circle.fill" />
          <Text modclass="italic type-size-small">
            <%= @error %>
          </Text>
        <% end %>
      </HStack>
      <HStack modclass="scroll-disabled">
        <TextField name="login_code" modclass="text-field-plain overlay:steps align-leading kerning-46 w-300 keyboard-type-numbers-and-punctuation">
          <HStack template={:steps} modclass="offset-x--6">
            <%= for _ <- 0..5 do %>
              <%= if assigns[:error] do %>
                <RoundedRectangle modclass="stroke:errorcolor h-48 w-48 overlay:step-bg" corner-radius="8">
                  <RoundedRectangle template={:step_bg} modclass="fg-color:errorcolor opacity-0.125 h-48 w-48" corner-radius="8" />
                </RoundedRectangle>
              <% else %>
                <RoundedRectangle modclass="stroke:lightchrome h-48 w-48" corner-radius="8" />
              <% end %>
            <% end %>
          </HStack>
        </TextField>
      </HStack>
      <Spacer modclass="h-64" />
      <LiveSubmitButton modclass="w-full h-56 background:rect">
        <Spacer />
        <Text modclass="fg-color-white font-weight-semibold type-size-x-large">Log In</Text>
        <Spacer />
        <RoundedRectangle modclass="fg-color:elixirpurple" corner-radius="8" template={:rect} />
      </LiveSubmitButton>
    </LiveForm>
    """
  end

  defp welcome_message(%{platform_id: :swiftui} = assigns) do\
    ~SWIFTUI"""
    <VStack id="welcome">
      <Text modclass="font-title font-weight-semibold p-16">Welcome to ElixirConf 2023 Chat!</Text>
      <Text modclass="line-spacing-8 font-weight-light">To get started, enter the email address you used to register for ElixirConf 2023</Text>
    </VStack>
    """
  end
end
