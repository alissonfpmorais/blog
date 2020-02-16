defmodule Blog.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar, :string, virtual: true
    field :email, :string
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :avatar, :username])
    |> validate_required([:name, :email, :username])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:username, min: 3, max: 25)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, required: true)
    |> password_hash()
  end

  defp password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
