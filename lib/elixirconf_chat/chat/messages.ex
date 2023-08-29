defmodule ElixirconfChat.Chat.Messages do
  import Ecto.Query
  alias ElixirconfChat.Repo
  alias ElixirconfChat.Message

  @doc """
  Sets deleted_at for all Messages belonging to a user.
  """
  def delete_messages_for_user(user_id) do
    now = DateTime.now()

    query =
      from m in Message,
        where: m.user_id == ^user_id,
        update: [set: [deleted_at: ^now]]

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:messages, query, [])
    |> Repo.transaction()
  end
end
