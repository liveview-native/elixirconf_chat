defmodule ElixirconfChat.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text
      add :first_name, :text
      add :last_name, :text

      timestamps()
    end
  end
end
