defmodule Instagrok.Likes do
  @moduledoc """
  The Likes context.
  """

  import Ecto.Query, warn: false
  alias Instagrok.Repo

  alias Instagrok.Likes.Like
  alias Instagrok.Accounts.User

  @doc """
  Creates a like with a given %User{} and the liked post or comment
  """
  def create_like(%User{} = user, liked_thing) do
    # creates a like with the user_id
    # user = Ecto.build_assoc(user, :likes)
    # creates the a like with the liked_id (that is supposed to be the id of the liked post)
    # being the id of the post, and then, adds the user_id from the previous struct created
    # using the %{user_id: value} field (3rd parameter of build_assoc)
    # like = Ecto.build_assoc(liked_thing, :likes, user)
    like = %Like{liked_id: liked_thing.id, user_id: user.id}

    # __struct__ returns the module of the struct, here is it used to diffrenciate
    # between the Post or the Comment
    update_total_likes = liked_thing.__struct__ |> where(id: ^liked_thing.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: 1])
    |> Repo.transaction()
  end

  @doc """
  Delete a like with a given %User{} and the post or comment that was unliked
  """
  def unlike(%User{} = user, liked_thing) do
    like = get_like(user.id, liked_thing)
    update_total_likes = liked_thing.__struct__ |> where(id: ^liked_thing.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: -1])
    |> Repo.transaction()
  end

  defp get_like(user_id, liked_thing) do
    Enum.find(liked_thing.likes, &(&1.user_id == user_id))
  end

  def liked?(%User{} = user, liked_thing) do
    Enum.any?(liked_thing.likes, &(&1.user_id == user.id))
  end

  def liked?(nil, _liked_thing) do
    nil
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
