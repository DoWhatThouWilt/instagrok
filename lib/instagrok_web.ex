defmodule InstagrokWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use InstagrokWeb, :controller
      use InstagrokWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: InstagrokWeb

      import Plug.Conn
      import InstagrokWeb.Gettext
      alias InstagrokWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/instagrok_web/templates",
        namespace: InstagrokWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {InstagrokWeb.LayoutView, "live.html"}

      unquote(view_helpers())
      alias Instagrok.Accounts.User
      alias Instagrok.Accounts

      @impl true
      def handle_params(params, uri, socket) do
        if Map.has_key?(params, "username") do
          %{"username" => username} = params
          user = Accounts.get_user_by_username(username)

          {:noreply,
           socket
           |> assign(current_uri_path: URI.parse(uri).path)
           |> assign(user: user, page_title: "#{user.full_name} #{user.username}")}
        else
          {:noreply,
           socket
           |> assign(current_uri_path: URI.parse(uri).path)}
        end
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import InstagrokWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import InstagrokWeb.ErrorHelpers
      import InstagrokWeb.Gettext
      alias InstagrokWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
