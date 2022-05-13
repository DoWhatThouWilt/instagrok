defmodule InstagrokWeb.UserLive.Profile do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias InstagrokWeb.UserLive.FollowComponent

  def mount(%{"username" => username}, _session, socket) do
    {:ok,
     socket
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
end
