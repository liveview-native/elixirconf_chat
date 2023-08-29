defmodule ElixirconfChat.Repo.Migrations.AddDeletedAtToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :deleted_at, :naive_datetime
    end
  end
end
