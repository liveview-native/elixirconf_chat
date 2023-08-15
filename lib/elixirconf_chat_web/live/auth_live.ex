defmodule ElixirconfChatWeb.AuthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  import ElixirconfChatWeb.SharedComponents, only: [logo: 1]

  alias ElixirconfChat.Auth
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  on_mount ElixirconfChatWeb.LiveSession

  native_binding :token, :string, default: "", persist: :global

  @impl true
  def mount(_params, _session, socket) do
    case socket.assigns do
      %{current_user: %User{}, platform_id: :swiftui} ->
        {:ok, push_navigate(socket, to: "/chat")}

      _ ->
        {:ok, socket}
    end
  end

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack modifiers={multiline_text_alignment(alignment: :center) |> text_field_style(style: :rounded_border)}}>
      <Spacer />
      <.logo platform_id={:swiftui} height={256} width={256} />
      <VStack>
        <%= if assigns[:user] do %>
          <.login_code_form platform_id={:swiftui} />
        <% else %>
          <.email_form platform_id={:swiftui} />
        <% end %>
        <%= if assigns[:error] do %>
          <Text id="error" modifiers={foreground_style({:color, :red})}>
            <%= @error %>
          </Text>
        <% end %>
      </VStack>
      <TextField modclass="hidden" value-binding="token" />
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
      socket =
        socket
        |> assign_native_bindings(%{token: token}) # TODO: Fix this
        |> push_navigate(to: "/chat", replace: true)

      {:noreply, socket}
    else
      {:login_code_valid?, false} ->
        {:noreply, assign(socket, error: "That code did not match the email associated.")}

      _ ->
        {:noreply, assign(socket, error: "Your login code has expired. Please go back and try again.")}
    end
  end

  ###

  defp email_form(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="email" phx-submit="check_email">
      <.welcome_message platform_id={:swiftui} />
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
    """
  end

  defp login_code_form(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="login_code" phx-submit="verify_code">
      <Text>Check your email for the six digit code.</Text>
      <TextField name="login_code" modifiers={frame(height: 48) |> text_input_autocapitalization(autocapitalization: :never)}>
        Login Code
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
    """
  end

  defp welcome_message(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack id="welcome">
      <Text>Welcome to ElixirConf 2023 Chat!</Text>
      <Spacer modifiers={frame(height: 8)} />
      <HStack modifiers={multiline_text_alignment(alignment: :center)}>
        <Spacer />
        <Text>Enter your email you used to register to get started</Text>
        <Spacer />
      </HStack>
    </VStack>
    """
  end

  def modclass(native, "hidden") do
    native
    |> hidden(true)
  end
end
