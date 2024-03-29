defmodule Instagrok.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Instagrok.Repo

  alias Instagrok.Posts.Post
  alias Instagrok.Accounts.User

  def get_post_by_url_id!(id) do
    Repo.get_by!(Post, url_id: id)
    |> Repo.preload([:user, :likes])
  end

  def paginate_user_posts(params, user_id) do
    Post
    |> where(user_id: ^user_id)
    |> order_by(desc: :id)
    |> Repo.paginate(params)
  end

  def delete_all_posts(user_id) do
    from(p in Post, where: p.user_id == ^user_id)
    |> Repo.delete_all()
  end

  @doc """
  Returns the list of paginated posts of a given user id.

  ## Examples

    iex> list_user_posts(page: 1, per_page: 10, user_id: 1)
    [%{photo_url: "", url_id: ""}, ...]
  """
  def list_profile_posts(page: page, per_page: per_page, user_id: user_id) do
    Post
    |> select([p], map(p, [:url_id, :photo_url]))
    |> where(user_id: ^user_id)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> order_by(desc: :id)
    |> Repo.all()
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Repo.get!(Post, id)
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Creates a post.
  """
  def create_post(%Post{} = post, attrs \\ %{}, user) do
    post = Ecto.build_assoc(user, :posts, put_url_id(post))
    changeset = Post.changeset(post, attrs)
    update_posts_count = from(u in User, where: u.id == ^user.id)

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      :update_posts_count,
      update_posts_count,
      inc: [posts_count: 1]
    )
    |> Ecto.Multi.insert(:post, changeset)
    |> Repo.transaction()
  end

  # Generates a base64-encoding 8 bytes
  # https://hashrocket.com/blog/posts/the-adventures-of-generating-random-numbers-in-erlang-and-elixir#how-to-generate-a-secure-random-string
  def put_url_id(post) do
    url_id = Base.encode64(:crypto.strong_rand_bytes(8), padding: false)

    %Post{post | url_id: url_id}
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
