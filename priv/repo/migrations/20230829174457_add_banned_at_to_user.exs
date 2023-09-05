defmodule ElixirconfChat.Repo.Migrations.AddBannedAtToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :banned_at, :naive_datetime
    end
  end
end
