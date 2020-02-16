defmodule BlogWeb.SessionController do
  @moduledoc """
  Controller to handle all requisitions to session resource
  """

  use BlogWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"identifier" => identifier, "password" => given_pass}}) do
    {identifier_type, authentication} =
      if is_email?(identifier) do
        {"email", Blog.Accounts.authenticate_by_email_and_password(identifier, given_pass)}
      else
        {"username", Blog.Accounts.authenticate_by_username_and_password(identifier, given_pass)}
      end

    case authentication do
      {:ok, user} ->
        conn
        |> BlogWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid #{identifier_type}/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> BlogWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp is_email?(identifier) do
    Regex.match?(~r/@/, identifier)
  end
end
