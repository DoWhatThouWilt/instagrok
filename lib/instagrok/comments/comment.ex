defmodule Instagrok.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema

  schema "comments" do
    field :body, :string
    field :total_likes, :integer
    belongs_to :post, Instagrok.Posts.Post
    belongs_to :user, Instagrok.Accounts.User
    has_many :likes, Instagrok.Likes.Like, foreign_key: :liked_id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
