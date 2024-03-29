defmodule Instagrok.Accounts.User do
  use Ecto.Schema
  import Ecto.Schema
  import Ecto.Changeset

  alias Instagrok.Accounts.Follows

  schema "users" do
    field :email, :string
    field :username, :string
    field :full_name, :string
    field :avatar_url, :string, default: "/images/default-avatar.png"
    field :bio, :string
    field :website, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime
    field :followers_count, :integer, default: 0
    field :following_count, :integer, default: 0
    field :posts_count, :integer, default: 0
    has_many :following, Follows, foreign_key: :follower_id
    has_many :followers, Follows, foreign_key: :followed_id
    has_many :posts, Instagrok.Posts.Post
    has_many :likes, Instagrok.Likes.Like
    has_many :comments, Instagrok.Comments.Comment

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :username, :full_name, :avatar_url, :bio, :website])
    |> validate_required([:username, :full_name])
    |> validate_length(:username, min: 5, max: 30)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_.-]*$/,
      message: "Please use letters and numbers without space(only characters allowed _ . -)"
    )
    |> validate_website()
    |> unique_constraint(:username)
    |> unsafe_validate_unique(:username, Instagrok.Repo)
    |> validate_length(:full_name, min: 4, max: 30)
    |> validate_email()
    |> validate_password(opts)
  end

  def validate_website(changeset) do
    validate_change(changeset, :website, fn :website, website ->
      case EctoFields.URL.cast(website) do
        {:ok, _website} ->
          []

        :error ->
          [website: "Enter a valid website"]
      end
    end)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Instagrok.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    register_user? = Keyword.get(opts, :register_user, true)

    if register_user? do
      changeset
      |> validate_required([:password])
      |> validate_length(:password, min: 6, max: 80)
      # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
      # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
      # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
      |> maybe_hash_password(opts)
    else
      changeset
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Instagrok.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
