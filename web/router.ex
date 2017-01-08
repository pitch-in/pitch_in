defmodule PitchIn.Router do
  use PitchIn.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PitchIn do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/asks", AskController, only: [:index, :show]
    resources "/campaigns", CampaignController do
      resources "/asks", AskController
    end
    resources "/users", UserController
    resources "/pros", ProController
    resources "/answers", AnswerController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PitchIn do
  #   pipe_through :api
  # end
end
