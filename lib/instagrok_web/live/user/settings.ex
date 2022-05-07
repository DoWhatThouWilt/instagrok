defmodule InstagrokWeb.UserLive.Settings do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  on_mount InstagrokWeb.UserLiveAuth

  alias Instagrok.Accounts
  # alias Instagrok.Accounts.User
  alias InstagrokWeb.Uploaders.Avatar

  @extension_whitelist ~w(.jpg .jpeg .png)

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(model_username: nil)
     |> assign(page_title: "Edit Profile")
     |> assign(changeset: changeset)
     |> allow_upload(
       :avatar_url,
       accept: @extension_whitelist,
       max_file_size: 9_000_000,
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:model_username, Map.get(user_params, "username"))
     |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_redirect(to: Routes.live_path(socket, InstagrokWeb.UserLive.Settings))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  # Updates the socket when the upload form changes, triggers handle_progress()
  def handle_event("upload_avatar", _params, socket) do
    IO.puts("upload_avatar event triggered")
    {:noreply, socket}
  end

  defp handle_progress(:avatar_url, entry, socket) do
    if entry.done? do
      avatar_url = Avatar.get_avatar_url(socket, entry)
      user_params = %{"avatar_url" => avatar_url}

      case Accounts.update_user(socket.assigns.current_user, user_params) do
        {:ok, _user} ->
          Avatar.update(socket, socket.assigns.current_user.avatar_url, entry)
          # update the current user and assign it back to the socket to get
          # the header nav thumbnail automatically updated
          current_user = Accounts.get_user!(socket.assigns.current_user.id)

          {:noreply,
           socket
           |> put_flash(:info, "Avatar updated successfully!")
           |> assign(current_user: current_user)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end
end
