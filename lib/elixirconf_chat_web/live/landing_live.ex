defmodule ElixirconfChatWeb.LandingLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  alias ElixirconfChat.Users.User

  on_mount ElixirconfChatWeb.LiveSession

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LoadingView />
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello world on the web!</div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: "/auth")}
  end
end
