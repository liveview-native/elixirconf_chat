defmodule ElixirconfChat.Repo.Migrations.AddRandomizeCodeOnLoginToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :randomize_code_on_login, :boolean, default: true
    end
  end
end
