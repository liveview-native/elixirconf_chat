defmodule ElixirconfChat.Utils do
  def server_time do
    DateTime.now!("UTC")
  end

  def time_range_formatted(from, to, timezone \\ "EST") do
    from = from |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(timezone)
    to = to |> DateTime.from_naive!("Etc/UTC") |> DateTime.shift_zone!(timezone)

    time_formatted(from) <> " - " <> time_formatted(to)
  end

  def time_formatted(time) do
    Calendar.strftime(time, "%I:%M%p")
  end
end
