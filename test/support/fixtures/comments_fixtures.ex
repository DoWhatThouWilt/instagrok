defmodule Instagrok.CommentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Instagrok.Comments` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body",
        total_likes: 42
      })
      |> Instagrok.Comments.create_comment()

    comment
  end
end
