defmodule ElixirconfChatWeb.PrivacyPolicyLive do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-4 bg-brand-purple flex items-center align-center font-system">
      <div class="mx-auto w-full max-w-[500px] p-4 min-[448px]:p-12 sm:p-15 bg-white rounded-[32px]">
        <.logo logo_title={true} {assigns} />
        <div class="text-center pt-8">
          <h1 class="text-xl font-semibold">Privacy Policy</h1>
          <p class="m-2 font-normal text-brand-gray-600">
            The ElixirConf 2023 Chat app stores the email addresses and names of attendees, and any messages that are sent through the app.
            <br>
            No other personal information is stored.
          </p>
          <a class="text-brand-purple font-semibold opacity-90 hover:opacity-100" href="/">Go Back</a>
        </div>
      </div>
    </div>
    """
  end

  ###

  def logo(assigns) do
    ~H"""
    <div class="text-center text-sm text-brand-gray-700 font-semibold uppercase tracking-[3px]">
      <img class="mx-auto" src="/images/elixir-logo.png" width="75" height="60" alt="" />
      <h1 class="mt-3">ElixirConf Chat</h1>
    </div>
    """
  end
end
