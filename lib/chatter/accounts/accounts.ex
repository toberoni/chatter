defmodule Chatter.Accounts do
  use Ash.Domain

  resources do
    resource Chatter.Accounts.User
    resource Chatter.Accounts.Token
  end
end
