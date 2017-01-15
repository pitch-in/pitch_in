defmodule PitchIn.Router do
  use PitchIn.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PitchIn.Auth, repo: PitchIn.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PitchIn do
    pipe_through :browser # Use the default browser stack

    get "/", AskController, :index
    resources "/asks", AskController, only: [:show]
    resources "/campaigns", CampaignController do
      resources "/asks", AskController do
        resources "/answers", AnswerController
      end
    end
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/pros", ProController, only: [:show, :update]
    get "/email_test", EmailTestController, :test
  end

  # Other scopes may use custom stacks.
  # scope "/api", PitchIn do
  #   pipe_through :api
  # end
end
