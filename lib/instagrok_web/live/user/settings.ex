defmodule InstagrokWeb.UserLive.Settings do
  use InstagrokWeb, :live_view
  import Phoenix.LiveView
  alias Instagrok.Accounts
  on_mount InstagrokWeb.UserLiveAuth

  @tabs %{
    profile: InstagrokWeb.UserLive.EditProfile,
    password: InstagrokWeb.UserLive.ChangePassword
  }

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(socket.assigns.current_user)
    password_changeset = Accounts.change_user_password(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:tabs, @tabs)
     |> assign(:password_changeset, password_changeset)
     |> assign(:page_title, "Settings")
     |> assign(:changeset, changeset)}
  end

  def active_tab?(action, tab) do
    if to_string(action) == tab do
      "border-l-2 border-black -ml-0.5 text-gray-900 font-semibold"
    else
      "hover:border-l-2 -ml-0.5 hover:border-gray-300 hover:bg-gray-50"
    end
  end
end
