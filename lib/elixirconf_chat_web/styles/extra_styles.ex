defmodule ElixirconfChatWeb.Styles.ExtraStyles do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "image-scale-" <> image_scale do
    imageScale(to_ime(image_scale))
  end
  """

  def class(_, _), do: {:unmatched, []}
end
