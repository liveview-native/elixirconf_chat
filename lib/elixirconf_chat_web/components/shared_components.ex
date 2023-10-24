defmodule ElixirconfChatWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Image class="stretch w-82 h-82 offset-y-8" name="Logo" />
      <Text class="capitalize type-size-xSmall kerning-2 font-weight-semibold">ElixirConf Chat</Text>
    </VStack>
    """
  end
end
