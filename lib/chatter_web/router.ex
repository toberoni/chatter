defmodule ChatterWeb.Router do
  use ChatterWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    # ash
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]

    # ash
    plug :load_from_bearer
  end

  scope "/", ChatterWeb do
    pipe_through :browser

    ash_authentication_live_session :authentication_required,
      on_mount: {ChatterWeb.LiveUserAuth, :live_user_required} do
      live "/", RoomsLive.Index, :index
      live "/room/:id", RoomsLive.Show, :show
    end

    sign_out_route AuthController
  end

  scope "/", ChatterWeb do
    pipe_through :browser

    get "/", PageController, :home
    # Leave out `register_path` and `reset_path` if you don't want to support
    # user registration and/or password resets respectively.
    # reset_path: "/reset"

    # hide sign-in for logged-in users
    sign_in_route(
      register_path: "/register",
      on_mount: [{ChatterWeb.LiveUserAuth, :live_no_user}]
    )

    auth_routes_for Chatter.Accounts.User, to: AuthController
    reset_route []
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatterWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chatter, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
