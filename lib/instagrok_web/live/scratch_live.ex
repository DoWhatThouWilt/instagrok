defmodule InstagrokWeb.ScratchLive do
  use InstagrokWeb, :live_view
  alias Phoenix.LiveView.JS
  alias Instagrok.{Comments}
  alias Instagrok.Comments.Comment
  on_mount InstagrokWeb.UserLiveAuth

  def mount(_params, _session, socket) do
    comment_changeset = Comments.change_comment(%Comment{})

    post =
      Instagrok.Posts.Post
      |> Ecto.Query.first()
      |> Instagrok.Repo.one()
      |> Instagrok.Repo.preload([:likes, :comments])

    comment = post.comments |> List.first() |> Instagrok.Repo.preload([:user, :likes])

    {:ok,
     socket
     |> assign(:comment_changeset, comment_changeset)
     |> assign(:post, post)
     |> assign(:comment, comment)}
  end

  def render(assigns) do
    ~H"""
    <.form let={f} for={@comment_changeset}>
      <%= text_input f, :body, phx_hook: "DisableSubmit" %>

      <!-- Disable button when there is no text in the input
        using JS hook
    <button type="submit" id="submit" disabled>Submit</button>
    -->
    <%= submit "Save", id: "submit", disabled: "" %>
      </.form>

    <button
      class="border text-lg px-6 py-2 rounded"
      phx-click={toggle_dropdown()}
    >Toggle</button>
      <ul class="w-56 shadow hidden" id="dropdown" phx-click-away={toggle_dropdown()}>
        <li>Content</li>
        <li>Other</li>
      </ul>

    <div class="w-96 bg-red-50">
      <.live_component
        module={InstagrokWeb.PostLive.CommentComponent}
        id={:some_comment}
        comment={@comment}
        current_user={@current_user}
      />
    </div>

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
