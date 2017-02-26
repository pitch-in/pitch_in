defmodule PitchIn.Router do
  use PitchIn.Web, :router
  
  pipeline :static do
    plug :accepts, ["html"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_csrf_token_in_header
    plug :put_secure_browser_headers
    plug PitchIn.Auth, repo: PitchIn.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PitchIn do
    pipe_through :browser # Use the default browser stack

    get "/", AskController, :index
    get "/campaigns/:id/interstitial", CampaignController, :interstitial
    resources "/campaigns", CampaignController do
      get "/asks/:id/interstitial", AskController, :interstitial
      resources "/asks", AskController do
        get "/answers/:id/interstitial", AnswerController, :interstitial
        resources "/answers", AnswerController
      end
    end
    get "/users/:id/interstitial", UserController, :interstitial
    resources "/users", UserController
    resources "/search_alerts", SearchAlertController, only: [:delete]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/pros", ProController, only: [:show, :update]
    resources "/contact_us", ContactUsController, only: [:index, :create]
  end

  scope "/", PitchIn do
    pipe_through :static

    get "/robots.txt", StaticKeyController, :robots
    get "/.well-known/acme-challenge/:cert_id", StaticKeyController, :cert
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
