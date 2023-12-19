defmodule ElixirconfChatWeb.Layouts do
  use ElixirconfChatWeb, :html
  use LiveViewNative.Layouts
  use ElixirconfChatWeb.Styles.AppStyles

  embed_templates "layouts/*.html"
end
