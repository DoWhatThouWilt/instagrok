defmodule Instagrok.Repo.Migrations.AddUsersUniqueUsernameIndex do
  use Ecto.Migration
  import Ecto.Migration

  def change do
    create unique_index(:users, [:username])
  end
end
