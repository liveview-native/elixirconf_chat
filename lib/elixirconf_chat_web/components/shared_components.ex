defmodule ElixirconfChatWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  def app_header(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack>
      <.logo height={48} width={48} native={@native} platform_id={:swiftui} />
    </HStack>
    """
  end

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Image modifiers={resizable(resizing_mode: :stretch) |> frame(height: @height, width: @width)} name="Logo" />
    """
  end
end
