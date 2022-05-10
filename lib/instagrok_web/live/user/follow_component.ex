defmodule InstagrokWeb.UserLive.FollowComponent do
  use InstagrokWeb, :live_component
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <button
      id="follow_btn"
      phx-target={@myself}
      phx-click={toggle_status(@follow_state)}
      class={@follow_state}
      >
      <%= @follow_state %>
    </button>
    """
  end

  def handle_event("toggle", %{"state" => state}, socket) do
    IO.inspect(state |> toggle_following)

    {:noreply,
     socket
     |> assign(:follow_state, toggle_following(state))}
  end

  defp toggle_following("follow") do
    "unfollow"
  end

  defp toggle_following("unfollow") do
    "follow"
  end

  defp toggle_status(js \\ %JS{}, state) do
    js
    |> JS.remove_class(state, to: "#follow_btn")
    |> JS.add_class(toggle_following(state), to: "#follow_btn")
    |> JS.push("toggle", value: %{state: state})
  end
end
