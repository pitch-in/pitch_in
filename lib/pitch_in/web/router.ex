defmodule PitchIn.Web.Router do
  use PitchIn.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug
  import PitchIn.Web.Auth, only: [verify_admin: 2]
  
  pipeline :static do
    plug :accepts, ["html"]
  end

  pipeline :browser do
    plug PitchIn.Web.StagingAuth
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_csrf_token_in_header
    plug :put_secure_browser_headers
    plug PitchIn.Web.Auth, repo: PitchIn.Repo
    plug PitchIn.Web.IncompleteReminder
  end

  pipeline :admin do
    plug :verify_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PitchIn.Web do
    pipe_through :browser # Use the default browser stack

    get "/", HomepageController, :index
    get "/search", SearchController, :index
    get "/campaigns/:id/interstitial", CampaignController, :interstitial
    resources "/campaigns", CampaignController do
      get "/asks/:id/interstitial", AskController, :interstitial
      resources "/prefill-asks", PrefilledAskController, only: [:index, :create]
      resources "/asks", AskController do
        get "/answers/:id/interstitial", AnswerController, :interstitial
        resources "/answers", AnswerController, only: [:index, :show, :new, :create, :edit, :update]
      end
      get "/answers/:id/interstitial", AnswerController, :interstitial
      resources "/answers", AnswerController, only: [:index, :show, :new, :create, :edit, :update]
    end
    get "/users/:id/interstitial", UserController, :interstitial
    get "/answers", AnswerController, :volunteer_index
    resources "/users", UserController, only: [:new, :create, :show, :edit, :update]
    get "/forgot-password/email-sent", ForgotPasswordController, :email_sent
    resources "/forgot-password", ForgotPasswordController, only: [:index, :create, :update]
    resources "/search-alerts", SearchAlertController, only: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/pros", ProController, only: [:show, :update]
    resources "/contact-us", ContactUsController, only: [:index, :create]
    get "/privacy-policy", HtmlController, :privacy_policy
    get "/about-us", HtmlController, :about_us
    get "/faq", HtmlController, :faq
    get "/donate-thanks", HtmlController, :donate_thanks
  end

  scope "/", PitchIn.Web do
    pipe_through :static

    get "/robots.txt", StaticKeyController, :robots
    get "/.well-known/acme-challenge/:cert_id", StaticKeyController, :cert
  end

  scope "/admin", PitchIn.Web.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/dashboard", DashboardController, :index
    resources "/campaigns", CampaignController, only: [:index, :update]
  end

  scope "/api", PitchIn.Web.Api, as: :api do
    pipe_through [:api]

    resources "/issues", IssueController, only: [:index]
  end

  def put_csrf_token_in_header(conn, _) do
    token = Phoenix.Controller.get_csrf_token

    conn
    |> Plug.Conn.put_resp_header("x-csrf-token", token)
  end

end
