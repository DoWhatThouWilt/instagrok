defmodule InstagrokWeb.PageLive do
  use InstagrokWeb, :live_view
  on_mount InstagrokWeb.UserLiveAuth
  alias Instagrok.Accounts
  alias Instagrok.Accounts.User
  import Phoenix.LiveView

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign(trigger_submit: false)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(live_action: apply_action(socket.assigns.current_user))}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    IO.inspect(user_params)

    changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket |> assign(trigger_submit: true)}
  end

  defp apply_action(current_user) do
    if !current_user, do: :root_path
  end
end
