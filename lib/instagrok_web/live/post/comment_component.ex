defmodule InstagrokWeb.PostLive.CommentComponent do
  use InstagrokWeb, :live_component

  alias InstagrokWeb.Uploaders.Avatar
  alias Instagrok.Comments

  def handle_event("delete", _params, socket) do
    case Comments.delete_comment(socket.assigns.comment) do
      {:ok, %{delete_comment: deleted_comment}} ->
        send(self(), {:delete_comment, deleted_comment})

        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
