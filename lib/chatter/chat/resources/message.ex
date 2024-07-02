defmodule Chatter.Chat.Message do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    domain: Chatter.Chat

  actions do
    defaults [:read]

    create :create do
      accept [:content, :room_id]

      validate string_length(:content, max: 100)
      change relate_actor(:author)
    end
  end

  attributes do
    integer_primary_key :id

    attribute :content, :string do
      allow_nil? false
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :room, Chatter.Chat.Room, allow_nil?: false, attribute_type: :integer
    belongs_to :author, Chatter.Accounts.User, allow_nil?: false
  end

  sqlite do
    table "messages"
    repo Chatter.Repo
  end
end
