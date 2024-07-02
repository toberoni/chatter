defmodule Chatter.Chat do
  use Ash.Domain

  resources do
    resource Chatter.Chat.Message

    resource Chatter.Chat.Room do
      define :join_room, args: [:user], action: :join
      define :leave_room, args: [:user], action: :leave
      define :open_room, args: [:name], action: :open
      # define :room_with_messages,
    end

    resource Chatter.Chat.RoomUser
  end
end
