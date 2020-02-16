defmodule Blog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :avatar, :string
      add :username, :string
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email, :username])
  end
end
