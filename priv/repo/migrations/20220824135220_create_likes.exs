defmodule Instagrok.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      # add :liked_id, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :delete_all)
      add :comment_id, references(:comments, on_delete: :delete_all)

      timestamps()
    end

    # create index(:likes, [:user_id, :liked_id])
    create index(:likes, [:user_id])
    create index(:likes, [:post_id])
    create index(:likes, [:comment_id])
  end
end
