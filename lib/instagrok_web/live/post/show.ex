defmodule InstagrokWeb.PostLive.Show do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias Instagrok.Posts
  alias InstagrokWeb.Uploaders.Avatar

  def mount(%{"id" => id}, _session, socket) do
    # live_redirect linking to the post encodes the url_id, and
    # Base.encode64() that generates the ids, may sometimes add
    # special characters that need to be encoded in the URL
    post = Posts.get_post_by_url_id!(URI.decode(id))

    {:ok, socket |> assign(post: post)}
  end
end
