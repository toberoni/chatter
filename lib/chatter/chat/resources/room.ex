defmodule Chatter.Chat.Room do
  use Ash.Resource,
    data_layer: AshSqlite.DataLayer,
    domain: Chatter.Chat,
    authorizers: [Ash.Policy.Authorizer]

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

    update :join_room do
      argument :user, :map, allow_nil?: false
      # change relate_actor(:users)

      validate attribute_equals(:private, false) do
        message "This room is private"
      end

      change manage_relationship(:user, :users, type: :create)
    end

    update :leave_room do
      argument :user, :map, allow_nil?: false
      change manage_relationship(:user, :users, type: :remove)
    end

    update :make_private do
      filter expr(private: false)
      change set_attribute(:private, true)
    end

    update :make_public do
      validate attribute_equals(:private, true) do
        message "Room is already private"
      end

      change set_attribute(:private, false)
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :private, :boolean, default: false, public?: true

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

  policies do
    policy action([:public_rooms]) do
      description "users can see all owned or public rooms"
      # authorize_if relates_to_actor_via(:owner)
      authorize_if expr(private == false)
    end

    policy action([:read]) do
      description "users can see all own or public rooms"
      # user owns room
      authorize_if relates_to_actor_via(:owner)
      # authorize_if relating_to_actor(:owner)
      # user joined room
      authorize_if relates_to_actor_via(:users)
      # authorize_if relating_to_actor(:users)
      authorize_if expr(private == false)
      # authorize_if always()
    end

    policy action(:open) do
      description("users can create rooms that they own")
      # user will be related as owner
      authorize_if relating_to_actor(:owner)
    end

    policy action([:make_public, :make_private]) do
      description "users can make rooms that they own private or public"
      authorize_if relates_to_actor_via(:owner)
    end

    policy action(:join_room) do
      description "users can join their own rooms, or public rooms"
      authorize_if relates_to_actor_via(:owner)
      authorize_if expr(private == false)
    end

    policy action(:leave_room) do
      description "users can leave all joined rooms"
      authorize_if relates_to_actor_via(:users)
    end

    # policy action_type(:destroy) do
    #   description "users can delete their own rooms"
    #   authorize_if relates_to_actor_via(:owner)
    # end
  end

  def owner_room_limit do
    @owner_room_limit
  end
end
