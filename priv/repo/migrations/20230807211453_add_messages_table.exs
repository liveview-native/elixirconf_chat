defmodule ElixirconfChat.Repo.Migrations.AddMessagesTable do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text, null: false
      add :room_id, references(:rooms), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
