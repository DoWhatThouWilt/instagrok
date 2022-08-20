defmodule Instagrok.Likes do
  @moduledoc """
  The Likes context.
  """

  import Ecto.Query, warn: false
  alias Instagrok.Repo

  alias Instagrok.Likes.Like
  alias Instagrok.Posts.Post
  alias Instagrok.Accounts.User

  @doc """
  Creates a like with the id of a given user and the liked post
  """
  def create_like(%User{} = user, %Post{} = liked_post) do
    # creates a like with the user_id
    # user = Ecto.build_assoc(user, :likes)
    # creates the a like with the liked_id (that is supposed to be the id of the liked post)
    # being the id of the post, and then, adds the user_id from the previous struct created
    # using the %{user_id: value} field (3rd parameter of build_assoc)
    # like = Ecto.build_assoc(liked_post, :likes, user)
    like = %Like{liked_id: liked_post.id, user_id: user.id}

    update_total_likes = Post |> where(id: ^liked_post.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: 1])
    |> Repo.transaction()
  end

  @doc """
  Delete a like with the id of a given user and the post that was unliked
  """
  def unlike(%User{} = user, %Post{} = liked_post) do
    like = get_like(user.id, liked_post)
    update_total_likes = Post |> where(id: ^liked_post.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: -1])
    |> Repo.transaction()
  end

  defp get_like(user_id, liked_post) do
    Enum.find(liked_post.likes, &(&1.user_id == user_id))
  end

  @doc """
  Returns the list of likes.

  ## Examples

      iex> list_likes()
      [%Like{}, ...]

  """
  def list_likes do
    Repo.all(Like)
  end

  @doc """
  Gets a single like.

  Raises `Ecto.NoResultsError` if the Like does not exist.

  ## Examples

      iex> get_like!(123)
      %Like{}

      iex> get_like!(456)
      ** (Ecto.NoResultsError)

  """
  def get_like!(id), do: Repo.get!(Like, id)

  @doc """
  Creates a like.

  ## Examples

      iex> create_like(%{field: value})
      {:ok, %Like{}}

      iex> create_like(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_like(attrs \\ %{}) do
    %Like{}
    |> Like.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a like.

  ## Examples

      iex> update_like(like, %{field: new_value})
      {:ok, %Like{}}

      iex> update_like(like, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_like(%Like{} = like, attrs) do
    like
    |> Like.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a like.

  ## Examples

      iex> delete_like(like)
      {:ok, %Like{}}

      iex> delete_like(like)
      {:error, %Ecto.Changeset{}}

  """
  def delete_like(%Like{} = like) do
    Repo.delete(like)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking like changes.

  ## Examples

      iex> change_like(like)
      %Ecto.Changeset{data: %Like{}}

  """
  def change_like(%Like{} = like, attrs \\ %{}) do
    Like.changeset(like, attrs)
  end
end
