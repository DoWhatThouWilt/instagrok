defmodule InstagrokWeb.PostLive.CommentComponent do
  use InstagrokWeb, :live_component

  alias InstagrokWeb.Uploaders.Avatar
  alias Instagrok.Comments

  def handle_event("delete", _params, socket) do
    case Comments.delete_comment(socket.assigns.comment) do
      {:ok, comment} ->
        send(self(), {:delete_comment, comment})

        {:noreply,
         socket
         |> put_flash(:info, "Deleted comment successfully!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:danger, "There was a problem deleting the comment!")}
    end
  end
end
