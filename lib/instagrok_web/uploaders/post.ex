defmodule InstagrokWeb.Uploaders.Post do
  alias InstagrokWeb.Router.Helpers, as: Routes
  alias Instagrok.Posts.Post
  import Phoenix.LiveView

  @upload_directory_path "priv/static/uploads"
  # @upload_directory_path Path.join([:code.priv_dir(:instagrok), "static", "uploads"])

  # returns the extension associated with a given MIME type
  defp ext(entry) do
    MIME.extensions(entry.client_type) |> hd()
  end

  def put_image_url(socket, %Post{} = post) do
    {completed, []} = uploaded_entries(socket, :photo_url)

    urls =
      for entry <- completed do
        Routes.static_path(
          socket,
          "/uploads/#{entry.uuid}.#{ext(entry)}"
        )
      end

    %Post{post | photo_url: List.to_string(urls)}
  end

  def save(socket) do
    if !File.exists?(@upload_directory_path), do: File.mkdir!(@upload_directory_path)

    consume_uploaded_entries(socket, :photo_url, fn %{path: path}, entry ->
      dest = Path.join(@upload_directory_path, "#{entry.uuid}.#{ext(entry)}")
      File.cp!(path, dest)

      {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
    end)
  end
end
