defmodule Instagrok.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias Instagrok.Repo

  alias Instagrok.Comments.Comment
  alias Instagrok.Posts.Post

  @doc """
  returns paginated comments with the following sort behavior:
  logged out: oldest first
  logged in on own post: your own comments then newest first
  logged in on somebody else's post: newest first
  """
  def list_post_comments(assigns, public: public) do
    user = assigns.current_user

    Comment
    |> get_sorting(public, user)
    |> preload([:user, :likes])
    |> Repo.paginate(assigns)
  end

  defp get_sorting(queryable, public, user) do
    if public do
      queryable |> order_by(asc: :id)
    else
      # https://learnsql.com/blog/order-by-specific-value/
      # https://manusachi.com/blog/sql-case-ecto#index
      # https://stackoverflow.com/questions/53713241/sql-order-by-specific-value-first-then-ordering
      # sql magicks, put the current user's comments first, then everyone else's
      queryable |> order_by(fragment("CASE when user_id = ? then 0 else 1 end", ^user.id))
    end
  end

  @doc """
  Creates a comment for a post and updates the total comments count in the
  parent post, then returns the comment created with its likes preloaded
  """
  def create_comment(user, post, attrs \\ %{}) do
    update_total_comments = Post |> where(id: ^post.id)
    comment_changeset = %Comment{} |> Comment.changeset(attrs)

    comment =
      comment_changeset
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.put_assoc(:post, post)

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:update_total_comments, update_total_comments,
      inc: [total_comments: 1]
    )
    |> Ecto.Multi.insert(:comment, comment)
    |> Repo.transaction()
    |> case do
      {:ok, %{comment: comment}} ->
        comment |> Repo.preload(:likes)
    end
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id) do
    Repo.get!(Comment, id)
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
