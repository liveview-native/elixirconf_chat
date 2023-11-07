defmodule ElixirconfChatWeb.AuthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView, stylesheet: ElixirconfChatWeb.Styles.AppStyles

  alias ElixirconfChat.Auth
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  @impl true
  def mount(params, _session, socket) do
    case params["email"] do
      nil ->
        {:ok, assign(socket, error: nil, login_code_buffer: "", user: nil)}

      email ->
        {:ok, assign(socket, error: nil, login_code_buffer: "", user: Users.get_user_by_email(email))}
    end
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack class="align-center text-field-roundedBorder">
      <.logo logo_title={true} {assigns} />
      <Spacer class="h-24" />
      <VStack class="p-24">
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
    <div id="main"class="min-h-screen p-4 bg-brand-purple flex items-center align-center font-system" phx-hook="ValidateAuthToken">
      <div class="mx-auto w-full max-w-[288px] min-[448px]:max-w-[412px] min-[532px]:max-w-[500px] p-4 min-[448px]:p-12 min-[532px]:p-15 bg-white rounded-[32px]">
      <.logo logo_title={true} {assigns} />
      <%= if assigns[:user] do %>
        <.login_code_form {assigns} />
      <% else %>
        <.email_form {assigns} />
      <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("check_email", %{"email" => email}, socket) do
    with {:user, %User{} = user} <- {:user, Users.get_user_by_email(email)},
         {:user_with_code, {:ok, %User{} = user_with_code}} <-
           {:user_with_code, Auth.randomize_user_login_code(user)},
         {:ok, _result} <- deliver_login_email(user_with_code)
    do
      {:noreply, push_navigate(socket, to: "/?email=#{email}", replace: false)}
    else
      {:user, nil} ->
        {:noreply,
         assign(socket,
           error: "There was no user associated. Try again or contact the conference staff.",
           user: nil
         )}

      {:user_with_code, _error} ->
        {:noreply,
         assign(socket,
           error:
             "An unexpected error has occurred. Please contact the conference staff for support.",
           user: nil
         )}
    end
  end

  @impl true
  def handle_event("verify_code", %{"login_code" => login_code}, socket) do
    with login_code <- parse_login_code(login_code),
          %User{id: user_id, login_code: user_login_code} when is_binary(user_login_code) <-
           Map.get(socket.assigns, :user),
         {:login_code_valid?, true} <- {:login_code_valid?, login_code == user_login_code},
         token <- Auth.generate_token(user_id) do
      {:noreply, push_navigate(socket, to: "/chat?token=#{token}", replace: false)}
    else
      {:login_code_valid?, false} ->
        {:noreply, assign(socket, error: "The code doesn't match")}

      _ ->
        {:noreply,
         assign(socket, error: "Your login code has expired. Please go back and try again.")}
    end
  end

  def handle_event("set_login_code_buffer", %{"login_code" => login_code}, socket) do
    {:noreply, assign(socket, login_code_buffer: login_code)}
  end

  ###

  def logo(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Image class="stretch w-82 h-82 offset-y-8" name="Logo" />
      <Text class="capitalize type-size-xSmall kerning-2 font-weight-semibold">ElixirConf Chat</Text>
    </VStack>
    """
  end

  def logo(assigns) do
    ~H"""
    <div class="text-center text-sm text-brand-gray-700 font-semibold uppercase tracking-[3px]">
      <img class="mx-auto" src="/images/elixir-logo.png" width="75" height="60" alt="" />
      <h1 class="mt-3">ElixirConf Chat</h1>
    </div>
    """
  end

  defp email_form(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="email" phx-submit="check_email">
      <.welcome_message {assigns} />
      <Spacer class="h-48" />
      <HStack class="align-leading h-32">
        <Text>Your Email Address</Text>
        <Spacer />
      </HStack>
      <TextField name="email" class="disable-autocorrect autocapitalize-never h-42 p-8 text-field-plain overlay:rect type-size-xLarge align-leading">
        <RoundedRectangle class="stroke:lightchrome fg-color-clear" corner-radius="8" template={:rect} />
      </TextField>
      <Spacer class="h-32" />
      <LiveSubmitButton class="w-full h-56 background:rect">
        <Spacer />
        <Text class="fg-color-white font-weight-semibold type-size-xLarge">Log In</Text>
        <Spacer />
        <RoundedRectangle class="fg-color:elixirpurple" corner-radius="8" template={:rect} />
      </LiveSubmitButton>
      <%= if assigns[:error] do %>
        <Text class="fg-color-red">
          <%= @error %>
        </Text>
      <% end %>
    </LiveForm>
    """
  end

  defp email_form(assigns) do
    ~H"""
    <form id="email" phx-submit="check_email">
      <.welcome_message {assigns} />

      <div class="mt-12">
        <label for="email-input" class="text-lg text-black">Your Email Address</label>
        <input
          name="email"
          class="mt-2 w-full h-10 min-[448px]:h-14 p-3 text-lg min-[448px]:text-xl text-brand-gray-800 border border-brand-gray-200 rounded-lg outline-none transition duration-200 focus:bg-brand-gray-50 focus:ring-2 focus:ring-brand-purple disable-autocorrect autocapitalize-never"
          id="email-input"
        />
      </div>

      <button type="submit" class="mt-8 w-full h-14 bg-brand-purple text-xl text-semibold text-white rounded-lg border-2 border-transparent outline-none transition duration-200 hover:text-brand-purple hover:bg-white hover:border-brand-purple focus:ring-2 focus:ring-[#1ff4ff] disabled:bg-brand-gray-200 disabled:text-brand-gray-400 disabled:cursor-not-allowed disabled:border-transparent">
        Log In
      </button>
      <%= if assigns[:error] do %>
        <p class="mt-2 text-base text-center text-brand-red italic" id="email-error"><%= @error %></p>
      <% end %>
    </form>
    """
  end

  defp login_code_form(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="login_code" phx-submit="verify_code">
      <Text class="font-title font-weight-semibold p-8">Enter Code to access</Text>
      <Text class="line-spacing-8 font-weight-light">
        We’ve sent a unique code to your email address. Please enter it below to continue.
      </Text>
      <Spacer class="h-64" />
      <HStack class="h-12 offset-y--16 fg-color:errorcolor">
        <%= if assigns[:error] do %>
          <Image system-name="exclamationmark.circle.fill" />
          <Text class="italic type-size-small">
            <%= @error %>
          </Text>
        <% end %>
      </HStack>
      <HStack class="scroll-disabled">
        <ZStack>
          <TextField name="login_code" phx-change="set_login_code_buffer" class="text-field-plain align-leading kerning-46 w-300 keyboard-type-numbersAndPunctuation fg-color-clear">
          </TextField>
          <HStack class="offset-x--6">
            <%= for n <- 0..5 do %>
              <ZStack class="overlay:rect h-48 w-48">
                <%= if String.at(@login_code_buffer, n) do %>
                  <Text><%= String.at(@login_code_buffer, n) %></Text>
                <% end %>
                <%= if assigns[:error] do %>
                  <RoundedRectangle class="stroke:errorcolor h-48 w-48 overlay:step-bg" corner-radius="8">
                    <RoundedRectangle template={:step_bg} class="fg-color:errorcolor opacity-0.125 h-48 w-48" corner-radius="8" />
                  </RoundedRectangle>
                <% else %>
                  <RoundedRectangle class="stroke:lightchrome h-48 w-48" corner-radius="8" />
                <% end %>
              </ZStack>
            <% end %>
          </HStack>
        </ZStack>
      </HStack>
      <Spacer class="h-64" />
      <LiveSubmitButton class="w-full h-56 background:rect">
        <Spacer />
        <Text class="fg-color-white font-weight-semibold type-size-xLarge">Log In</Text>
        <Spacer />
        <RoundedRectangle class="fg-color:elixirpurple" corner-radius="8" template={:rect} />
      </LiveSubmitButton>
    </LiveForm>
    """
  end

  defp login_code_form(assigns) do
    ~H"""
    <form id="login_code" phx-submit="verify_code">
      <div class="mt-8 text-center">
        <h2 class="text-2xl min-[532px]:text-3.5xl font-semibold">Enter Code to access</h2>
        <p class="max-w-[360px] mx-auto mt-2 font-normal text-brand-gray-600">
          We’ve sent a unique code to your email address. Please enter it below to continue.
        </p>
      </div>
      <div class="relative mt-12 mb-[4.25rem] min-[532px]:mb-[4.75rem] w-full">
        <%= if assigns[:error] do %>
          <div class="absolute left-0 -top-7 w-full flex items-center justify-center text-brand-red">
            <.icon name="hero-exclamation-circle-solid" class="h-5 w-5" />
            <p class="ml-[10px] italic" id="login-code-error">
              <%= @error %>
            </p>
          </div>
        <% end %>
        <label for="login-code-input" class="sr-only">Your login code</label>
        <%= if assigns[:error] do %>
          <input
            type="text"
            name="login_code"
            class="min-[320px]:absolute min-[320px]:top-0 min-[320px]:-left-4 min-[448px]:-left-10 min-[532px]:left-[-3.25rem] w-full min-[320px]:w-[304px] min-[448px]:w-[398px] min-[532px]:w-[480px] mx-auto h-10 min-[448px]:h-14 py-3 min-[320px]:pl-7 min-[320px]:tracking-[1.9375rem] min-[448px]:pl-14 min-[532px]:pl-[4.75rem] font-monospace text-xl min-[532px]:text-2xl text-brand-red min-[448px]:tracking-[2.625rem] min-[532px]:tracking-[3.125rem] text-center min-[320px]:text-left rounded-lg border border-brand-gray-200 min-[320px]:border-0 min-[320px]:bg-transparent min-[320px]:overflow-x-hidden focus:outline-none focus:ring-1 focus:ring-brand-purple min-[320px]:focus:ring-0 peer"
            id="login-code-input"
            maxlength="6"
            inputmode="numeric"
          />
          <div class="hidden min-[320px]:flex justify-center gap-x-1.5 min-[448px]:gap-x-2 peer-focus:[&>div]:ring-1 min-[532px]:peer-focus:[&>div]:ring-2 peer-focus:[&>div]:ring-brand-purple [&>div]:border [&>div]:border-brand-red [&>div]:rounded-lg [&>div]:w-9 [&>div]:h-10 [&>div]:min-[448px]:w-[2.8125rem] [&>div]: [&>div]:min-[532px]:w-14 [&>div]:min-[448px]:h-14 [&>div]:bg-[#fef6f3]">
            <%= for _ <- 0..5 do %>
              <div></div>
            <% end %>
          </div>
        <% else %>
          <input
            type="text"
            name="login_code"
            class="min-[320px]:absolute min-[320px]:top-0 min-[320px]:-left-4 min-[448px]:-left-10 min-[532px]:left-[-3.25rem] w-full min-[320px]:w-[304px] min-[448px]:w-[398px] min-[532px]:w-[480px] mx-auto h-10 min-[448px]:h-14 py-3 min-[320px]:pl-7 min-[320px]:tracking-[1.9375rem] min-[448px]:pl-14 min-[532px]:pl-[4.75rem] font-monospace text-xl min-[532px]:text-2xl text-brand-gray-800 min-[448px]:tracking-[2.625rem] min-[532px]:tracking-[3.125rem] text-center min-[320px]:text-left rounded-lg border border-brand-gray-200 min-[320px]:border-0 min-[320px]:bg-transparent min-[320px]:overflow-x-hidden focus:outline-none focus:ring-1 focus:ring-brand-purple min-[320px]:focus:ring-0 peer"
            id="login-code-input"
            maxlength="6"
            inputmode="numeric"
          />
          <div class="hidden min-[320px]:flex justify-center gap-x-1.5 min-[448px]:gap-x-2 peer-focus:[&>div]:ring-1 min-[532px]:peer-focus:[&>div]:ring-2 peer-focus:[&>div]:ring-brand-purple [&>div]:border [&>div]:border-brand-gray-200 [&>div]:rounded-lg [&>div]:w-9 [&>div]:h-10 [&>div]:min-[448px]:w-[2.8125rem] [&>div]: [&>div]:min-[532px]:w-14 [&>div]:min-[448px]:h-14">
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
          </div>
        <% end %>
        <div class="hidden min-[448px]:block absolute -right-10 top-0 w-10 h-full rounded bg-white" aria-hidden="true"></div>
      </div>
      <button type="submit" class="mt-8 w-full h-14 bg-brand-purple text-xl text-semibold text-white rounded-lg border-2 border-transparent outline-none transition duration-200 hover:text-brand-purple hover:bg-white hover:border-brand-purple focus:ring-2 focus:ring-[#1ff4ff] disabled:bg-brand-gray-200 disabled:text-brand-gray-400 disabled:cursor-not-allowed disabled:border-transparent">
        Verify
      </button>
    </form>
    """
  end

  defp welcome_message(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack id="welcome">
      <VStack class="font-title font-weight-semibold p-16">
        <Text>Welcome to ElixirConf</Text>
        <Text>2023 Chat</Text>
      </VStack>
      <VStack class="line-spacing-8 font-weight-light">
        <Text>To get started, enter the email address</Text>
        <Text>you used to register for ElixirConf 2023</Text>
      </VStack>
    </VStack>
    """
  end

  defp welcome_message(assigns) do
    ~H"""
    <div class="mt-8 text-center" id="welcome">
      <h2 class="text-2xl min-[532px]:text-3.5xl font-semibold">Welcome to ElixirConf 2023 Chat!</h2>
      <p class="mt-2 font-normal text-brand-gray-600">
        To get started, enter the email address you used to register for ElixirConf 2023
      </p>
    </div>
    """
  end

  # Allow heroicons to be used
  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  defp deliver_login_email(user) do
    user
    |> ElixirconfChat.Auth.LoginEmail.login_email()
    |> ElixirconfChat.Mailer.deliver()
  end

  defp parse_login_code(login_code) do
    login_code
    |> String.trim()
    |> String.slice(0..5)
  end
end
