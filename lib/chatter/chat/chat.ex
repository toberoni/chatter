defmodule Chatter.Chat do
  use Ash.Domain

  resources do
    resource Chatter.Chat.Message

    resource Chatter.Chat.Room do
      define :open_room, args: [:name], action: :open
      # define :room_with_messages,
    end
  end
end
