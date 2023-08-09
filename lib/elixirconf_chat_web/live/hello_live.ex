defmodule ElixirconfChatWeb.HelloLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, push_navigate(socket, to: "/", replace: true)}
    else
      {:ok, socket}
    end
  end

  @impl true
  def render(%{platform_id: :swiftui} = assigns), do: ~SWIFTUI""
end
