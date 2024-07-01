defmodule Chatter.Chat.Room do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    domain: Chatter.Chat

  @owner_room_limit 2

  actions do
    defaults [:read, :destroy]

    create :open do
      accept [:name]

      validate string_length(:name, max: 100)
      change relate_actor(:owner)

      validate fn changeset, %{actor: owner} ->
        owned_rooms = Ash.load!(owner, :rooms) |> Map.get(:rooms) |> Enum.count()

        if owned_rooms >= owner_room_limit() do
          {:error, field: :name, message: "you can only open #{owner_room_limit()} rooms"}
        else
          :ok
        end
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :messages, Chatter.Chat.Message
    belongs_to :owner, Chatter.Accounts.User, allow_nil?: false
  end

  sqlite do
    table "rooms"
    repo Chatter.Repo

    references do
      reference :owner, on_delete: :delete, on_update: :update
    end
  end

  def owner_room_limit do
    @owner_room_limit
  end
end
