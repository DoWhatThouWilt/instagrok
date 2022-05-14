defmodule InstagrokWeb.CurrentURIPath do
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    socket = attach_hook(socket, :get_current_uri_path, :handle_params, fn
      _params, url, socket ->
        {:cont, assign(socket, :current_uri_path, URI.parse(url).path)}
    end)
    {:cont, socket}
  end
end
