defmodule BlogWeb.Auth do
  @moduledoc """
  Controller to handle all requisitions to session resource
  """

  import Plug.Conn
  import Phoenix.Controller
  alias BlogWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] && conn.assigns.current_user.avatar ->
        conn

      user = conn.assigns[:current_user] ->
        user = put_avatar(user)
        assign(conn, :current_user, user)

      user = user_id && Blog.Accounts.get_user!(user_id) ->
        user = put_avatar(user)
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    user = put_avatar(user)

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end

  def authenticate_user(conn, _opts) do
    case conn do
      %Plug.Conn{assigns: %{current_user: %Blog.Accounts.User{}}} ->
        conn

      _ ->
        conn
        |> put_flash(:error, "You must be logged in to access that page!")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
    end
  end

  defp put_avatar(user) do
    gravatar = Blog.Accounts.gravatar_email_hash(user.email)
    Map.put(user, :avatar, gravatar)
  end
end
