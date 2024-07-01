defmodule Chatter.Accounts.Token do
  use Ash.Resource,
    domain: Chatter.Accounts,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  sqlite do
    table "tokens"
    repo Chatter.Repo
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
