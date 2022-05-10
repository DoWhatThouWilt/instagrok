defmodule Instagrok.Accounts.Follows do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema

  alias Instagrok.Accounts.User

  schema "account_follows" do
    belongs_to :following, User
    belongs_to :follower, User

    timestamps()
  end

  @doc false
  def changeset(follows, attrs) do
    follows
    |> cast(attrs, [])
    |> validate_required([])
  end
end
