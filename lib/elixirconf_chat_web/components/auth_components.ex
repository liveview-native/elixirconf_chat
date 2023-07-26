defmodule ElixirconfChatWeb.AuthComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Image modifiers={resizable(resizing_mode: :stretch) |> frame(height: 256, width: 256)} name="Logo" />
    """
  end
end
