# defmodule Chatter.Chat.Validations.OwnerRoomLimit do
#   use Ash.Resource.Validation

#   @owner_room_limit 2

#   @impl true
#   def init(opts) do
#     {:ok, opts}
#   end

#   @impl true
#   def validate(changeset, _opts, %{actor: owner}) do
#     owned_rooms = Ash.load!(owner, :chats) |> Enum.count()

#     if owned_rooms > @owner_room_limit do
#       {:error, message: "you can only open #{@owner_room_limit} rooms"}
#     else
#       :ok
#     end
#   end
# end
