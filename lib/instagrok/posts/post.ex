defmodule Instagrok.Posts.Post do
  use Ecto.Schema
  import Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :description, :string
    field :photo_url, :string
    field :total_comments, :integer
    field :total_likes, :integer
    field :url_id, :string
    belongs_to :user, Instagrok.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:url_id, :description, :photo_url])
    |> validate_required([:url_id, :description, :photo_url])
  end
end
