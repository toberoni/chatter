defmodule ChatterWeb.RoomsLive.Sidebar do
  use ChatterWeb, :live_component

  alias Chatter.Chat.Room

  @impl true
  def render(assigns) do
    ~H"""
    <div class="top-10 sticky flex flex-col my-8 gap-4">
      <h2 class="text-lg">Your rooms</h2>
      <.link
        :for={room <- @rooms}
        navigate={"/room/#{room.id}"}
        class="bg-slate-200 border border-slate-300 hover:bg-blue-100 hover:-translate-y-1 p-2 rounded-lg"
      >
        <%= room.name %>
      </.link>
      <div :if={@can_open} class="mt-8 flex border-t-2 border-slate-100">
        <.simple_form for={@form} phx-submit="open_room" phx-target={@myself}>
          <.input field={@form[:name]} label="Name" />
          <:actions>
            <.button>Open new room</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form =
      AshPhoenix.Form.for_create(Room, :open, as: "room", actor: assigns.current_user)
      |> to_form

    rooms = Ash.load!(assigns.current_user, :rooms) |> Map.get(:rooms)

    # only show
    can_open = Enum.count(rooms) < Room.owner_room_limit()

    {:ok, socket |> assign(form: form, rooms: rooms, can_open: can_open)}
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
end
