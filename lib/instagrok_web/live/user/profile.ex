defmodule InstagrokWeb.UserLive.Profile do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias Instagrok.Accounts
  alias InstagrokWeb.UserLive
  alias InstagrokWeb.UserLive.FollowComponent

  def mount(%{"username" => username}, _session, socket) do
    user = Accounts.get_user_by_username(username)

    {:ok,
     socket
     |> assign(user: user)
     |> assign(page_title: "@#{user.username}")
     |> assign(follow_state: "follow")
     |> assign(username: username)}
  end

  def follow_state(state) do
    state
  end

  def display_website_uri(site) do
    site
    |> URI.parse()
    |> Map.get(:host)
  end

  def handle_info({FollowComponent, :update_totals, updated_user}, socket) do
    {:noreply, socket |> assign(user: updated_user)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :following) do
    following =
      Accounts.list_following(socket.assigns.user)
      |> Enum.map(& &1.followed)

    socket |> assign(:follows, following)
  end

  defp apply_action(socket, :followers) do
    followers =
      Accounts.list_followers(socket.assigns.user)
      |> Enum.map(& &1.follower)

    socket |> assign(:follows, followers)
  end

  defp apply_action(socket, _) do
    socket
  end
end
