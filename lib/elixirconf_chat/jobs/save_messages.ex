defmodule ElixirconfChat.Jobs.SaveMessages do
  use Oban.Worker, queue: :events, max_attempts: 3
  require Logger

  alias Ecto.Multi
  alias ElixirconfChat.Chat.Message
  alias ElixirconfChat.Chat.Room
  alias ElixirconfChat.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("sync initiated")

    Room
    |> Repo.all()
    |> Enum.map(fn room ->
      ElixirconfChat.Chat.Server.get_state(room.id)[:messages]
      |> Enum.with_index()
      |> Enum.reduce(Multi.new(), fn {message, i}, multi ->
        message_params = Map.from_struct(message)

        message_changeset =
          Message.changeset(%Message{}, message_params)

        Multi.insert(multi, "#{i}", message_changeset)
      end)
      |> Multi.run(:clear_message_queue, fn _repo, _multi ->
        ElixirconfChat.Chat.Server.clear_message_queue(room.id)
      end)
      |> Repo.transaction()
    end)

    :ok

    # TODO
    # Logger.info("#{} messages saved")
  end
end
