defmodule ChatterWeb.RoomsLive.Sidebar do
  use ChatterWeb, :live_component

  alias Chatter.Chat.Room

  @impl true
  def render(assigns) do
    ~H"""
    <aside class="top-10 sticky flex flex-col my-8 gap-4">
      <h2 :if={Enum.any?(@owned_rooms)} class="text-lg">Your rooms</h2>
      <.room_link :for={room <- @owned_rooms} room={room} />

      <h2 :if={Enum.any?(@joined_rooms)} class="text-lg">Joined rooms</h2>
      <.room_link :for={room <- @joined_rooms} room={room} />
      <div :if={@can_open?} class="mt-8 flex border-t-2 border-slate-100">
        <.simple_form for={@form} phx-submit="open_room" phx-target={@myself}>
          <.input field={@form[:name]} label="Name" />
          <:actions>
            <.button>Open new room</.button>
          </:actions>
        </.simple_form>
      </div>
    </aside>
    """
  end

  @impl true
  def update(assigns, socket) do
    form =
      AshPhoenix.Form.for_create(Room, :open, as: "room", actor: assigns.current_user)
      |> to_form

    user = Ash.load!(assigns.current_user, [:owned_rooms, :joined_rooms])
    # only show

    {:ok,
     socket
     |> assign(
       form: form,
       owned_rooms: user.owned_rooms,
       joined_rooms: user.joined_rooms,
       can_open?: can_open?(user)
     )}
  end

  @impl true
  def handle_event("open_room", %{"room" => params}, socket) do
    form = socket.assigns.form

    case AshPhoenix.Form.submit(form, params: params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Entered '#{room.name}'.")
         |> push_navigate(to: "/room/#{room.id}")}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(form: form)}
    end
  end

  defp can_open?(user) do
    Enum.count(user.owned_rooms) < Room.owner_room_limit()
  end
end
