defmodule Instagrok.Repo.Migrations.CreateAccountFollows do
  use Ecto.Migration

  def change do
    create table(:account_follows) do
      add :following_id, references(:users, on_delete: :delete_all)
      add :follower_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:account_follows, [:following_id])
    create index(:account_follows, [:follower_id])
    create unique_index(:account_follows, [:following_id, :follower_id])
  end
end
