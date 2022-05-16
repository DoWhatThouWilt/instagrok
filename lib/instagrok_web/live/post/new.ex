defmodule InstagrokWeb.PostLive.New do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias InstagrokWeb.Router.Helpers, as: Routes
  alias Instagrok.Posts.Post
  alias Instagrok.Posts
  alias InstagrokWeb.Uploaders.Post, as: PostUploader

  @extension_whitelist ~w(.jpg .jpeg .png)

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "New Post")
     |> assign(changeset: Posts.change_post(%Post{}))
     |> allow_upload(:photo_url,
       accept: @extension_whitelist,
       max_file_size: 30_000_000
     )}
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      Instagrok.Posts.change_post(%Post{}, post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo_url, ref)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    post = PostUploader.put_image_url(socket, %Post{})

    case Posts.create_post(post, post_params, socket.assigns.current_user) do
      {:ok, _post} ->
        PostUploader.save(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(
           to: Routes.user_profile_path(socket, :index, socket.assigns.current_user.username)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
