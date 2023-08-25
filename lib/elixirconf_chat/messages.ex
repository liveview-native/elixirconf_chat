defmodule ElixirconfChat.Messages do
  alias ElixirconfChat.Repo
  alias ElixirconfChat.Chat.Message

  @doc """
  Fetches a Message by ID.
  """
  def get_message(id) do
    Repo.get(Message, id)
  end

  @doc """
  Creates a new Message using the given `attrs`.
  """
  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()
  end
end
