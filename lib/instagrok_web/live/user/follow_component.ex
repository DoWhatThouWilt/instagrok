defmodule InstagrokWeb.UserLive.FollowComponent do
  use InstagrokWeb, :live_component
  alias Phoenix.LiveView.JS
  alias Instagrok.Accounts
  import Phoenix.LiveView

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> get_follow_state}
  end

  # phx-click={toggle_status(@follow_state)}
  def render(assigns) do
    ~H"""
    <button
      id="follow_btn"
      phx-target={@myself}
      phx-click="toggle"
      class={@follow_state}
      >
      <%= @follow_state %>
    </button>
    """
  end

  def get_follow_state(socket) do
    if Accounts.following?(socket.assigns.current_user.id, socket.assigns.user.id) do
      socket |> assign(:follow_state, "unfollow")
    else
      socket |> assign(:follow_state, "follow")
    end
  end

  def handle_event("toggle", _params, socket) do
    follower = socket.assigns.current_user
    followed = socket.assigns.user

    if Accounts.following?(follower.id, followed.id) do
      unfollow(socket, follower.id, followed.id)
    else
      follow(socket, follower, followed)
    end
  end

  defp follow(socket, follower, followed) do
    updated_user = Accounts.create_follow(follower, followed)

    send(self(), {__MODULE__, :update_totals, updated_user})

    {:noreply,
     socket
     |> assign(:follow_state, "unfollow")}
  end

  defp unfollow(socket, follower_id, followed_id) do
    updated_user = Accounts.unfollow(follower_id, followed_id)

    send(self(), {__MODULE__, :update_totals, updated_user})

    {:noreply,
     socket
     |> assign(:follow_state, "follow")}
  end
end
