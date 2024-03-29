defmodule TodoWeb.Router do
  use TodoWeb, :router

  import TodoWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TodoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", TodoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/telemetry", metrics: TodoWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TodoWeb do
    pipe_through [:browser]

    get "/", PageController, :index
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
    get "/room/:schedule_id/:participant_id/:meeting_id", RoomController, :index
  end

  scope "/", TodoWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", UserRegistrationController, :new
    post "/register", UserRegistrationController, :create
    get "/log_in", UserSessionController, :new
    post "/log_in", UserSessionController, :create
    get "/reset_password", UserResetPasswordController, :new
    post "/reset_password", UserResetPasswordController, :create
    get "/reset_password/:token", UserResetPasswordController, :edit
    put "/reset_password/:token", UserResetPasswordController, :update
  end

  live_session :default, on_mount: {TodoWeb.Live.InitAssigns, :default} do
    scope "/", TodoWeb do
      pipe_through [:browser]

      live "/book/:slug", BookLive, :index
      live "/book/:slug/:schedule", BookLive, :set_schedule
    end
  end

  live_session :private, on_mount: {TodoWeb.Live.InitAssigns, :private} do
    scope "/users", TodoWeb do
      pipe_through [:browser, :require_authenticated_user]

      live "/dashboard", DashboardLive, :index
      live "/bookings", BookingLive, :index
      live "/availability", AvailabilityLive, :index
      live "/settings", SettingsLive, :index
      get "/settings/confirm_email/:token", UserSettingsController, :confirm_email
    end
  end

  # live_session :admin, on_mount: {TodoWeb.Live.InitAssigns, :admin} do
  #   score "/admin", TodoWeb do
  #     pipe_through [:browser, :require_authenticated_user]

  #     live "dashboard", DashboardLive, :index
  #   end
  # end
end
