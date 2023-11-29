defmodule ElixirconfChatWeb.Styles.LayoutStyles do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "italic" do
    italic(true)
  end
  """

  def class(_, _), do: {:unmatched, []}
end
