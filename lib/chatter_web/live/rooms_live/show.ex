defmodule ChatterWeb.RoomsLive.Show do
  use ChatterWeb, :live_view

  alias Chatter.Chat.Room
  alias Chatter.Chat.Message
  alias ChatterWeb.RoomsLive.Sidebar

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <.chat_grid>
      <:sidebar>
        <.live_component id="my-rooms" module={Sidebar} current_user={@current_user} />
      </:sidebar>

      <:main>
        <h1 class="mb-10 text-lg">Chat Room <%= @room.name %></h1>
        <.chat_window>
          <div :if={Enum.empty?(@messages)} class="text-lg text-center">
            This chat has no messages
          </div>

          <div :for={msg <- @messages} id={"message-#{msg.id}"} class="flex items-center gap-4">
            <span><%= msg.author.email %>:</span>
            <span class="grow-0 border border-slate-200 bg-slate-100 rounded-lg px-4 py-2">
              <%= msg.content %>
            </span>
          </div>
        </.chat_window>
        <div class="flex w-full">
          <.form
            for={@message_form}
            class="flex my-4 gap-4 w-full"
            phx-throttle="1000"
            phx-change="change_msg"
            phx-submit="send_msg"
          >
            <div class="w-full">
              <.input
                type="text"
                field={@message_form[:content]}
                value={@msg_value}
                autofocus="true"
                autocomplete="off"
              />
            </div>
            <.button class="mt-2 px-8 py-2">Send</.button>
          </.form>
        </div>
        <.back navigate="/">Back to chat overview</.back>
      </:main>
    </.chat_grid>
    """
  end

  @impl true

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(%{"id" => room_id}, _uri, socket) do
    # replace with Chat.room_with_messages?
    room = Ash.get!(Room, String.to_integer(room_id)) |> Ash.load!(messages: :author)

    messages = room.messages
    room = Map.drop(room, messages)

    {:noreply,
     socket
     |> assign(room: room, messages: messages)
     |> assign_message_form()}
  end

  @impl true
  def handle_event("send_msg", %{"message" => params}, socket) do
    form = socket.assigns.message_form

    case AshPhoenix.Form.submit(form, params: Map.put(params, "room_id", socket.assigns.room.id)) do
      {:ok, message} ->
        {:noreply,
         socket
         |> assign(messages: socket.assigns.messages ++ [message])
         |> assign_message_form()
         |> push_patch(to: "/room/#{socket.assigns.room.id}")}

      {:error, form} ->
        {:noreply, assign(socket, message_form: form)}
    end
  end

  @impl true
  def handle_event("change_msg", %{"message" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.message_form, params)

    # update the message content in the form field so it gets deleted after submitting the form (liveview doesn't reset the input field)
    %{"content" => content} = params

    {:noreply, assign(socket, message_form: form, msg_value: content)}
  end

  defp assign_message_form(socket) do
    new =
      AshPhoenix.Form.for_create(Message, :create,
        as: "message",
        actor: socket.assigns.current_user
      )
      |> to_form

    assign(socket, message_form: new, msg_value: nil)
  end
end
