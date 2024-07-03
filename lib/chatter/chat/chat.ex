defmodule Chatter.Chat do
  use Ash.Domain

  resources do
    resource Chatter.Chat.Message

    resource Chatter.Chat.Room do
      define :make_room_private, action: :make_private
      define :make_room_public, action: :make_public
      define :join_room, args: [:user], action: :join_room
      define :leave_room, args: [:user], action: :leave_room
      define :open_room, args: [:name], action: :open
    end

    resource Chatter.Chat.RoomUser
  end
end
