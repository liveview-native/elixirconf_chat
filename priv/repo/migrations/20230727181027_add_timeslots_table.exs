defmodule ElixirconfChat.Repo.Migrations.AddTimeslotsTable do
  use Ecto.Migration

  def change do
    create table(:timeslots) do
      add :starts_at, :naive_datetime
      add :ends_at, :naive_datetime
      add :timezone, :string, default: "EST"
      add :formatted_string, :string
    end
  end
end
