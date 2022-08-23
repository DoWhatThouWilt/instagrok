defmodule InstagrokWeb.PostLive.Show do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias Instagrok.Posts
  alias InstagrokWeb.Uploaders.Avatar
  alias InstagrokWeb.PostLive.LikeComponent
  alias Instagrok.Comments
  alias Instagrok.Comments.Comment

  def mount(%{"id" => id}, _session, socket) do
    # live_redirect linking to the post encodes the url_id, and
    # Base.encode64() that generates the ids, may sometimes add
    # special characters that need to be encoded in the URL
    post = Posts.get_post_by_url_id!(URI.decode(id))

    {:ok,
     socket
     |> assign(changeset: Comments.change_comment(%Comment{}))
     |> assign(comments_section_update: "prepend")
     |> assign(post: post)
     |> assign(page: 1, page_size: 15)
     |> assign_comments()
     |> set_load_more_comments_btn(), temporary_assigns: [comments: []]}
  end

  def handle_info({LikeComponent, :update_post_likes, post_id}, socket) do
    {:noreply,
     socket
     |> assign(post: Posts.get_post!(post_id))}
  end

  def handle_info({LikeComponent, :update_comment_likes, comment_id}, socket) do
    comment = Comments.get_comment!(comment_id)

    {:noreply,
     socket
     |> update(:comments, fn comments -> [comment | comments] end)}
  end

  defp assign_comments(%{assigns: assigns} = socket) do
    current_user = assigns.current_user

    if current_user do
      page = Comments.list_post_comments(assigns, public: false)
      socket |> assign(comments: page.entries, total_pages: page.total_pages)
    else
      page = Comments.list_post_comments(assigns, public: true)
      socket |> assign(comments: page.entries, total_pages: page.total_pages)
    end
  end

  defp set_load_more_comments_btn(%{assigns: assigns} = socket) do
    total_comments = assigns.post.total_comments
    page_size = assigns.page_size

    if total_comments > page_size do
      socket |> assign(load_more_comments_btn: "flex")
    else
      socket |> assign(load_more_comments_btn: "hidden")
    end
  end

  def handle_event("load-more-comments", _, socket) do
    {:noreply,
     socket
     |> assign(comments_section_update: "append")
     |> load_comments()}
  end

  def handle_event("save", %{"comment" => comment_param}, %{assigns: assigns} = socket) do
    %{"body" => body} = comment_param
    current_user = assigns.current_user
    post = assigns.post

    if body == "" do
      # no text is entered
      {:noreply, socket}
    else
      comment = Comments.create_comment(current_user, post, comment_param)

      {:noreply,
       socket
       # add new comment
       |> update(:comments, fn comments -> [comment | comments] end)
       |> assign(comments_section_update: "prepend")
       # fresh changeset
       |> assign(changeset: Comments.change_comment(%Comment{}))}
    end
  end

  defp load_comments(%{assigns: %{page: page, total_pages: total_pages}} = socket) do
    socket
    |> hide_btn?(page, total_pages)
    |> update(:page, &(&1 + 1))
    |> assign_comments()
  end

  defp hide_btn?(socket, page, total_pages) do
    if page + 1 == total_pages do
      socket |> assign(load_more_comments_btn: "hidden")
    else
      socket
    end
  end
end
