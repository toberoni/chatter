defmodule Chatter.Chat.RoomUser do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    domain: Chatter.Chat

  alias Chatter.Chat.Room
  alias Chatter.Accounts.User

  actions do
    defaults [:read, :destroy, create: :*]
  end

  sqlite do
    table "room_users"
    repo Chatter.Repo
  end

  relationships do
    belongs_to :room, Room, primary_key?: true, allow_nil?: false, attribute_type: :integer
    belongs_to :user, User, primary_key?: true, allow_nil?: false
  end
end
