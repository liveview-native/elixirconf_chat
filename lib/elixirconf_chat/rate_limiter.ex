defmodule ElixirconfChat.RateLimiter do
  use GenServer

  @delay_ms 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def log_chat(user_id) do
    ETS.KeyValueSet.put!(set(), user_id, now())
  end

  def recent_chat?(user_id) do
    now = now()
    case ETS.KeyValueSet.get!(set(), user_id) do
      nil -> false
      date when date + @delay_ms > now -> true
      _ -> false
    end
  end

  @impl GenServer
  def init(:ok) do
    ETS.KeyValueSet.new!(name: __MODULE__, protection: :public)
    {:ok, :ok}
  end

  defp set do
    ETS.KeyValueSet.wrap_existing!(__MODULE__)
  end

  def now, do: System.system_time(:millisecond)
end
