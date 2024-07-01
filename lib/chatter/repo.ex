defmodule Chatter.Repo do
  use AshSqlite.Repo,
    otp_app: :chatter
    #adapter: Ecto.Adapters.SQLite3
end
