defmodule ElixirconfChat.Repo.Migrations.AddTimestampsToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      timestamps()
    end
  end
end
