defmodule PitchIn.Router do
  use PitchIn.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  import PitchIn.Auth, only: [verify_admin: 2]
  
  pipeline :static do
    plug :accepts, ["html"]
  end

  pipeline :browser do
    plug PitchIn.StagingAuth
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_csrf_token_in_header
    plug :put_secure_browser_headers
    plug PitchIn.Auth, repo: PitchIn.Repo
  end

  pipeline :admin do
    plug :verify_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PitchIn do
    pipe_through :browser # Use the default browser stack

    get "/", SearchController, :index
    get "/campaigns/:id/interstitial", CampaignController, :interstitial
    resources "/campaigns", CampaignController do
      get "/asks/:id/interstitial", AskController, :interstitial
      resources "/asks", AskController do
        get "/answers/:id/interstitial", AnswerController, :interstitial
        resources "/answers", AnswerController, only: [:index, :show, :new, :create]
      end
      get "/answers/:id/interstitial", AnswerController, :interstitial
      resources "/answers", AnswerController, only: [:index, :show, :new, :create]
    end
    get "/users/:id/interstitial", UserController, :interstitial
    get "/answers", AnswerController, :volunteer_index
    resources "/users", UserController, only: [:new, :create, :show, :edit, :update]
    resources "/search-alerts", SearchAlertController, only: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/pros", ProController, only: [:show, :update]
    resources "/contact-us", ContactUsController, only: [:index, :create]
    get "/privacy-policy", HtmlController, :privacy_policy
    get "/about-us", HtmlController, :about_us
    get "/donate-thanks", HtmlController, :donate_thanks
  end

  scope "/", PitchIn do
    pipe_through :static

    get "/robots.txt", StaticKeyController, :robots
    get "/.well-known/acme-challenge/:cert_id", StaticKeyController, :cert
  end

  scope "/admin", PitchIn.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/dashboard", DashboardController, :index
    get "/campaigns", CampaignController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PitchIn do
  #   pipe_through :api
  # end
  #
  def put_csrf_token_in_header(conn, _) do
    token = Phoenix.Controller.get_csrf_token

    conn
    |> Plug.Conn.put_resp_header("X-Csrf-Token", token)
  end

end
