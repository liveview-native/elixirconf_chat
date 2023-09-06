defmodule ElixirconfChat.Utils do
  @doc """
  Gets the current time in UTC.
  """
  def server_time do
    DateTime.utc_now()
  end

  @doc """
  Formats a `t:NaiveDateTime.t/0` as a time string like `"4:31AM"`.

  ## Examples

      iex> time_formatted(~N[2023-09-02 12:31:00.123456], "EST")
      "Sat 7:31AM"

      iex> time_formatted(~N[2023-09-02 12:31:00.123456])
      "Sat 8:31AM"

  """
  def time_formatted(time, timezone \\ "US/Eastern") do
    time = time |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(timezone)
    today = DateTime.shift_zone!(server_time(), timezone)

    if DateTime.diff(time, today, :hour) |> abs() < 24 do
      Calendar.strftime(time, "%-I:%M%p")
    else
      Calendar.strftime(time, "%a %-I:%M%p")
    end
  end

  @doc """
  Formats two `t:NaiveDateTime.t/0`s a time range string.

  ## Example

      iex> time_range_formatted(~N[2023-09-02 12:31:00], ~N[2023-09-02 16:31:00])
      "Sat 8:31AM - Sat 12:31PM"

  """
  def time_range_formatted(from, to, timezone \\ "US/Eastern") do
    time_formatted(from, timezone) <> " - " <> time_formatted(to, timezone)
  end
end
