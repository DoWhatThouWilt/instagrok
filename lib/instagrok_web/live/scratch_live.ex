defmodule InstagrokWeb.ScratchLive do
  use InstagrokWeb, :live_view
  alias Phoenix.LiveView.JS
  alias Instagrok.Accounts
  alias InstagrokWeb.UserLive.FollowComponent
  on_mount InstagrokWeb.UserLiveAuth

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:changeset, changeset)}
  end

  def render(assigns) do
    ~H"""
    <button
      class="border text-lg px-6 py-2 rounded"
      phx-click={toggle_dropdown()}
    >Toggle</button>
      <ul class="w-56 shadow hidden" id="dropdown" phx-click-away={toggle_dropdown()}>
        <li>Content</li>
        <li>Other</li>
      </ul>

    <.live_component
      module={FollowComponent}
      id={:follow}
      follow_state={"follow"}
    />
    """
  end

  def handle_event("test", %{"state" => state}, socket) do
    IO.inspect(state)
    {:noreply, socket}
  end

  defp toggle_dropdown(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#dropdown",
      in: {"ease-in duration-150", "opacity-0 scale-90", "opacity-100 scale-100"},
      out: {"ease-out duration-150", "opacity-100 scale-100", "opacity-0 scale-90"}
    )
    |> JS.push("test", value: %{state: true})
  end
end
