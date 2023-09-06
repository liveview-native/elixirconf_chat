defmodule ElixirconfChat.UtilsTest do
  use ExUnit.Case, async: true

  alias ElixirconfChat.Utils

  doctest ElixirconfChat.Utils, import: true

  describe "time_formatted/2" do
    test "formats time with days if the time is more than 24h" do
      assert "Thu 11:00AM" = Utils.time_formatted(~U[1970-01-01 11:00:00.123456Z], "Etc/UTC")
      assert "Fri 12:00PM" = Utils.time_formatted(~U[1970-01-02 12:00:00.123456Z], "Etc/UTC")
      assert "Sat 1:00PM" = Utils.time_formatted(~U[1970-01-03 13:00:00.123456Z], "Etc/UTC")
    end

    test "formats the time without days if less than 24h" do
      time = DateTime.utc_now()
      assert formatted = Utils.time_formatted(time, "Etc/UTC")
      assert Regex.match?(~r/^\d{1,2}:\d{2}(AM|PM)$/, formatted)
    end
  end
end
