defmodule ElixirconfChat.Repo.Migrations.AddMessagesTable do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text, null: false
      add :posted_at, :naive_datetime
      add :posted_by, :string
      add :room_id, references(:rooms), null: false
      add :user_id, references(:users), null: false
    end
  end
end
