defmodule ElixirconfChatWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Image modifiers={resizable(resizing_mode: :stretch) |> frame(height: @height, width: @width)} name="Logo" />
    """
  end
end
