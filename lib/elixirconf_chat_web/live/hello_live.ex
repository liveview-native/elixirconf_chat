defmodule ElixirconfChatWeb.HelloLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>Hello world on iOS!</Text>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello world on the web!</div>
    """
  end
end
