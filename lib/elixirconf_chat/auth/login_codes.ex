defmodule ElixirconfChat.Auth.LoginCodes do
  @login_code_lifetime 3_600

  @doc """
  Returns a `NaiveDateTime` for `n` seconds from now where
  `n` is the value of `@login_code_lifetime`.
  """
  def expires_at do
    NaiveDateTime.utc_now()
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(@login_code_lifetime, :second)
    |> DateTime.to_naive()
  end

  @doc """
  Returns a random, 6-digit login code.
  """
  def random_login_code do
    Stream.repeatedly(fn -> Enum.random(0..9) end)
    |> Enum.take(6)
    |> Enum.join()
  end
end
