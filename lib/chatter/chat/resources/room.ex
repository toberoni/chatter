defmodule Chatter.Chat.Room do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    domain: Chatter.Chat

  alias Chatter.Chat.{Message, RoomUser}
  alias Chatter.Accounts.User

  @owner_room_limit 2

  actions do
    defaults [:read, :destroy]

    read :public_rooms do
      filter expr(private: false)
    end

    create :open do
      accept [:name]

      validate string_length(:name, max: 100)
      change relate_actor(:owner)

      validate fn changeset, %{actor: owner} ->
        owned_rooms = Ash.load!(owner, :owned_rooms) |> Map.get(:owned_rooms) |> Enum.count()

        if owned_rooms >= owner_room_limit() do
          {:error, field: :name, message: "you can only open #{owner_room_limit()} rooms"}
        else
          :ok
        end
      end
    end

    update :join do
      argument :user, :map, allow_nil?: false
      change manage_relationship(:user, :users, type: :create)
    end

    update :leave do
      argument :user, :map, allow_nil?: false
      change manage_relationship(:user, :users, type: :remove)
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :private, :boolean, default: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :users, User do
      through RoomUser
      source_attribute_on_join_resource :room_id
      destination_attribute_on_join_resource :user_id
    end

    has_many :messages, Message
    belongs_to :owner, User, allow_nil?: false
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
