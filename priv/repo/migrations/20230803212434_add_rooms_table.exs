defmodule ElixirconfChat.Repo.Migrations.AddRoomsTable do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :title, :text, null: false
      add :track, :integer
      add :presenters, {:array, :text}, default: [], null: false
      add :timeslot_id, references(:timeslots), null: false
    end
  end
end
