defmodule Instagrok.Likes.Like do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema

  schema "likes" do
    # The id of the liked thing, post or comment 
    field :liked_id, :integer
    belongs_to :user, Instagrok.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:liked_id])
    |> validate_required([:liked_id])
  end
end
