defmodule Chatter.Accounts.Secrets do
  use AshAuthentication.Secret


  def secret_for([:authentication, :tokens, :signing_secret], Chatter.Accounts.User, _) do
    case Application.fetch_env(:chatter, ChatterWeb.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)
      :error ->
        :error
    end
  end
end
