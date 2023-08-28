defmodule ElixirconfChat.Auth.LoginEmail do
  import Swoosh.Email

  alias ElixirconfChat.Users.User

  def login_email(%User{} = user) do
    name = "#{user.first_name} #{user.last_name}"
    email_html = email_html(name, user.login_code)
    email_text = email_text(name, user.login_code)

    new()
    |> to({name, user.email})
    |> from({"DockYard", "noreply@dockyard.com"})
    |> subject("Your six digit code is #{user.login_code}")
    |> html_body(email_html)
    |> text_body(email_text)
  end

  ###

  defp email_html(name, login_code) do
    """
    <h1>Hello #{name},</h1>
    <p>Thank you for using the ElixirConf chat app.</p>
    <p>Your six digit code to login is <strong>#{login_code}</strong></p>
    """
  end

  defp email_text(name, login_code) do
    """
    Hello #{name},
    Thank you for using the ElixirConf chat app.
    Your six digit code to login is <strong>#{login_code}</strong>.
    """
  end
end
