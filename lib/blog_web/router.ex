defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BlogWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/panel", BlogWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/users", UserController, except: [:index, :new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end
end
