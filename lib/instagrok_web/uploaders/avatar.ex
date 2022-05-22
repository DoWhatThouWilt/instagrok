defmodule InstagrokWeb.Uploaders.Avatar do
  alias InstagrokWeb.Router.Helpers, as: Routes
  import Phoenix.LiveView
  import Mogrify

  @upload_directory_name "uploads"
  @upload_directory_path "priv/static/uploads"

  # returns the extension associated with a given MIME type
  defp ext(entry) do
    MIME.extensions(entry.client_type) |> hd()
  end

  @doc """
  Returns the url path for uploaded avatars
  """
  def get_avatar_url(socket, entry) do
    Routes.static_path(
      socket,
      "/#{@upload_directory_name}/#{entry.uuid}.#{ext(entry)}"
    )
  end

  def update(socket, old_url, entry) do
    # Creates the upload directory path if it doesn't exist 
    if !File.exists?(@upload_directory_path), do: File.mkdir!(@upload_directory_path)

    # Consumes an individual uploaded entry
    consume_uploaded_entry(socket, entry, fn %{} = meta ->
      # Destination paths for avatar thumbnails
      dest = Path.join(@upload_directory_path, "#{entry.uuid}.#{ext(entry)}")
      dest_thumb = Path.join(@upload_directory_path, "thumb_#{entry.uuid}.#{ext(entry)}")

      # meta.path is the temporary file path
      mogrify_thumbnail(meta.path, dest, 300)
      mogrify_thumbnail(meta.path, dest_thumb, 150)

      # removes the old avatar
      rm_file(old_url)
      # removes the old thumbnail
      old_url |> get_thumb() |> rm_file()

      # consuming uploads requires a tagged tuple
      {:ok,
       {Routes.static_path(socket, "/#{dest}"), Routes.static_path(socket, "/#{dest_thumb}")}}
    end)

    :ok
  end

  def get_thumb(avatar_url, opts \\ []) do
    # consider that the default avatar doesn't have a thumbnail
    maybe_default = Keyword.get(opts, :maybe_default, false)

    file_name = Path.basename(avatar_url)
    thumb_path = Path.join("/#{@upload_directory_name}", "thumb_#{file_name}")

    if maybe_default && !File.exists?(Path.join(@upload_directory_path, file_name)) do
      "/images/default-avatar.png"
    else
      thumb_path
    end
  end

  def rm_file(old_avatar_url) do
    url = Path.basename(old_avatar_url)
    path = Path.join(@upload_directory_path, url)
    if File.exists?(path), do: File.rm!(path)
  end

  defp mogrify_thumbnail(src_path, dst_path, size) do
    try do
      src_path
      |> open()
      |> resize_to_limit("#{size}x#{size}")
      |> save(path: dst_path)
    rescue
      File.Error -> {:error, :invalid_src_path}
      error -> {:error, error}
    else
      _image -> {:ok, dst_path}
    end
  end
end
