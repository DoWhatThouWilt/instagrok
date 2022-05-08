defmodule InstagrokWeb.UserLive.Profile do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  def mount(%{"username" => username}, _session, socket) do
    {:ok,
     socket
     |> assign(username: username)}
  end

  def display_website_uri(site) do
    site
    |> URI.parse()
    |> Map.get(:host)
  end
end
