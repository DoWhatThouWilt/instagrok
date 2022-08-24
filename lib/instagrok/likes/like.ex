defmodule Instagrok.Likes.Like do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema

  schema "likes" do
    # The id of the liked thing, post or comment 
    # field :liked_id, :integer
    belongs_to :user, Instagrok.Accounts.User
    belongs_to :post, Instagrok.Posts.Post
    belongs_to :comment, Instagrok.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:post_id, :comment_id])
  end
end
