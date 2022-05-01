defmodule InstagrokWeb.UserLiveAuth do
  import Phoenix.LiveView
  alias Instagrok.Accounts
  alias Instagrok.Accounts.User

  def on_mount(:default, _params, session, socket) do
    {:cont,
     socket
     |> assign_user(session)}
  end

  defp assign_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      # Accounts.get_user_by_session_token(token)
      find_current_user(session)
    end)
  end

  # here checking if the user_token key in the session is neccesary,
  # because without a logged in user, there is no
  # user_token key in the session, and pattern-
  # matching on it with %{"user_token" => session}
  # will not work. The landing page has two states
  # with an user present and not.
  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end
end
