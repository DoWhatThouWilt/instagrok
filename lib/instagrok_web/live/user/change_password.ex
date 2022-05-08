defmodule InstagrokWeb.UserLive.ChangePassword do
  use InstagrokWeb, :live_component
  import Phoenix.LiveView

  alias InstagrokWeb.Uploaders.Avatar
  alias Instagrok.Accounts

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def handle_event(
        "save",
        %{"user" => params},
        socket
      ) do
    %{"current_password" => current_password} = params

    case Accounts.update_user_password_without_logout(
           socket.assigns.current_user,
           current_password,
           params
         ) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password updated successfully.")
         |> push_redirect(to: InstagrokWeb.Router.Helpers.user_settings_path(socket, :password))}

      {:error, password_changeset} ->
        IO.inspect(password_changeset)
        {:noreply, assign(socket, :password_changeset, password_changeset)}
    end
  end
end
