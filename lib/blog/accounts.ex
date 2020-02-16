defmodule Blog.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by some param

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_by!(username: "gandalf")
      %User{}

      iex> get_by!(username: "sauron")
      ** (Ecto.NoResultsError)
  """
  def get_user_by!(attrs) do
    User
    |> Repo.get_by!(attrs)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Authenticate a user by checking the given email and password

  ## Examples

    iex> authenticate("right@email.com", "right_pass")
    {:ok, %User{}}

    iex> authenticate("right@email.com", "bad_pass")
    {:error, :unauthorized}

    iex> authenticate("wrong@email.com", "right_pass")
    {:error, :not_found}
  """
  def authenticate_by_email_and_password(email, given_pass) do
    get_user_by!(email: email)
    |> authenticate(given_pass)
  end

  @doc """
  Authenticate a user by checking the given username and password

  ## Examples

    iex> authenticate("right_user", "right_pass")
    {:ok, %User{}}

    iex> authenticate("right_user", "bad_pass")
    {:error, :unauthorized}

    iex> authenticate("wrong_user", "right_pass")
    {:error, :not_found}
  """
  def authenticate_by_username_and_password(username, given_pass) do
    get_user_by!(username: username)
    |> authenticate(given_pass)
  end

  @doc """
  Authenticate a user by checking the given password

  ## Examples

    iex> authenticate(%User{}, "right_pass")
    {:ok, %User{}}

    iex> authenticate(%User{}, "bad_pass")
    {:error, :unauthorized}

    iex> authenticate(nil, "right_pass")
    {:error, :not_found}
  """
  def authenticate(user, given_pass) do
    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  @doc """
  Generate a gravatar url from a given email

  ## Examples

      iex> gravatar_email_hash("johndoe@email.com")
      "https://www.gravatar.com/avatar/850cb023e169427bb9eb3f3b18d0f091?s=150&d=identicon"
  """
  def gravatar_email_hash(email) do
    hash = email_hash(email)
    "https://www.gravatar.com/avatar/#{hash}?s=340&d=identicon"
  end

  defp email_hash(email) do
    email
    |> String.trim()
    |> String.downcase()
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
  end
end
