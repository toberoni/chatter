defmodule ChatterWeb.RoomsLive.Index do
  use ChatterWeb, :live_view

  alias ChatterWeb.RoomsLive.Sidebar

  @impl true
  def render(assigns) do
    ~H"""
    <.chat_grid>
      <:sidebar>
        <.live_component id="my-rooms" module={Sidebar} current_user={@current_user} />
      </:sidebar>

      <:main>
        All public rooms
      </:main>
    </.chat_grid>
    """
  end
end
