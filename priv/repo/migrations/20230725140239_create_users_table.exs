defmodule ElixirconfChat.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text, null: false
      add :first_name, :text, null: false
      add :last_name, :text, null: false
      add :login_code, :string, size: 6
      add :login_code_expires_at, :naive_datetime

      timestamps()
    end
  end
end
