defmodule ElixirconfChat.Jobs.SaveMessages do
  use Oban.Worker, queue: :events, max_attempts: 3
  require Logger
  alias ElixirconfChat.Messages
  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("sync initiated")

    Room
    |> Repo.all()
    |> Enum.map(fn room ->
      messages = ElixirconfChat.Chat.Server.get_state(room.id)[:messages]

      Enum.map(messages, fn message ->
        # TODO: prevent duplicates
        if message.inserted_at == nil do
          now = DateTime.truncate(DateTime.utc_now(), :second)

          message
          |> Map.merge(%{inserted_at: now, updated_at: now})
          |> Map.from_struct()
          |> Messages.create_message()
        end
      end)
    end)

    :ok

    # TODO
    # Logger.info("#{} messages saved")
  end
end
