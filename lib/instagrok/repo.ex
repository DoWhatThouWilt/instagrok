defmodule Instagrok.Repo do
  use Ecto.Repo,
    otp_app: :instagrok,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
