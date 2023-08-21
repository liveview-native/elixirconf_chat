defmodule ElixirconfChat.Utils do
  def server_time do
    DateTime.now!("UTC")
  end

  def time_formatted(time, timezone \\ "EST") do
    time = time |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(timezone)

    strftime(time)
  end

  def time_range_formatted(from, to, timezone \\ "EST") do
    time_formatted(from, timezone) <> " - " <> time_formatted(to, timezone)
  end

  ###

  def strftime(time) do
    time
    |> Calendar.strftime("%I:%M%p")
    |> String.trim_leading("0")
  end
end
