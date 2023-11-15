defmodule ElixirconfChatWeb.Layouts do
  use ElixirconfChatWeb, :html

  embed_templates "layouts/*.html"
  embed_templates "layouts/*.swiftui", suffix: "_swiftui"
end
