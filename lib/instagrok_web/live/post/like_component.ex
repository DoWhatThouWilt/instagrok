defmodule InstagrokWeb.PostLive.LikeComponent do
  use InstagrokWeb, :live_component
  import Phoenix.LiveView

  alias Instagrok.Likes

  def render(assigns) do
    ~H"""
    <button
      phx-target={@myself}
      phx-click="toggle"
      class={"#{@dimensions} focus:outline-none"}
    >
      <%= if @is_liked? do %>
        <svg class="text-red-600" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd" />
        </svg>
      <% else %>
       <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
      <% end %>
    </button>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> get_like_state}
  end

  defp get_like_state(%{assigns: assigns} = socket) do
    if Likes.liked?(assigns.current_user, assigns.liked_thing) do
      socket |> assign(:is_liked?, true)
    else
      socket |> assign(:is_liked?, false)
    end
  end

  def handle_event("toggle", _params, %{assigns: assigns} = socket) do
    current_user = assigns.current_user
    liked_thing = assigns.liked_thing

    if Likes.liked?(current_user, liked_thing) do
      unlike(socket, current_user, liked_thing)
    else
      like(socket, current_user, liked_thing)
    end
  end

  defp unlike(socket, current_user, liked_thing) do
    Likes.unlike(current_user, liked_thing)
    send_msg_to_parent(liked_thing)

    {:noreply,
     socket
     |> assign(:is_liked?, false)}
  end

  defp like(socket, current_user, liked_thing) do
    Likes.create_like(current_user, liked_thing)
    send_msg_to_parent(liked_thing)

    {:noreply,
     socket
     |> assign(:is_liked?, true)}
  end

  defp send_msg_to_parent(liked_thing) do
    # this is a trick that gets the module name by pattern matching
    %module_name{} = liked_thing

    msg =
      case module_name do
        Instagrok.Posts.Post ->
          :update_post_likes

        Instagrok.Comments.Comment ->
          :update_comment_likes
      end

    send(self(), {__MODULE__, msg, liked_thing.id})
  end
end
