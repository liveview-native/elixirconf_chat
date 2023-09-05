defmodule ElixirconfChat.Chat.Messages do
  import Ecto.Query
  alias ElixirconfChat.Chat.Message
  alias ElixirconfChat.Repo
  alias ElixirconfChat.Chat.Room

  @doc """
  Sets deleted_at for all Messages belonging to a user.
  """
  def delete_messages_for_user(user_id) do
    now = DateTime.utc_now()

    query =
      from m in Message,
        where: m.user_id == ^user_id,
        update: [set: [deleted_at: ^now]]

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:messages, query, [])
    |> Ecto.Multi.run({:delete_banned_messages, user_id}, fn _repo, _multi ->
      results =
        Room
        |> Repo.all()
        |> Enum.map(fn room ->
          ElixirconfChat.Chat.Server.delete_banned_messages(room.id, user_id)
        end)

      {:ok, results}
    end)
    |> Repo.transaction()
  end
end
