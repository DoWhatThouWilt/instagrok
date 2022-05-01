defmodule InstagrokWeb.PageController do
  use InstagrokWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
