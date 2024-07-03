defmodule ChatterWeb.RoomsLive.Index do
  use ChatterWeb, :live_view

  alias ChatterWeb.RoomsLive.Sidebar
  alias Chatter.Chat.Room

  @impl true
  def render(assigns) do
    ~H"""
    <.chat_grid>
      <:sidebar>
        <.live_component id="my-rooms" module={Sidebar} current_user={@current_user} />
      </:sidebar>

      <:main>
        <h1 class="text-lg">All public rooms</h1>
        <div class="grid grid-cols-4 my-8 gap-4">
          <.room_link :for={room <- @rooms} room={room} />
        </div>
      </:main>
    </.chat_grid>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    rooms =
      Ash.Query.for_read(Room, :public_rooms, %{}, actor: socket.assigns.current_user)
      |> Ash.read!()

    {:ok, assign(socket, rooms: rooms)}
  end
end
