defmodule Chatter.Accounts.User do
  use Ash.Resource,
    domain: Chatter.Accounts,
    data_layer: AshSqlite.DataLayer,
    extensions: [AshAuthentication]

  actions do
    defaults [:read]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      enabled? true
      token_resource Chatter.Accounts.Token
      signing_secret Chatter.Accounts.Secrets
    end
  end

  sqlite do
    table "users"
    repo Chatter.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
