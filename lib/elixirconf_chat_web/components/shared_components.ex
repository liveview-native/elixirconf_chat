defmodule ElixirconfChatWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  def logo(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Image modclass="stretch w-82 h-82 offset-y-8" name="Logo" />
      <Text modclass="capitalize type-size-x-small kerning-2 font-weight-semibold">ElixirConf Chat</Text>
    </VStack>
    """
  end
end
