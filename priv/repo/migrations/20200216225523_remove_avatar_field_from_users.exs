defmodule Blog.Repo.Migrations.RemoveAvatarFieldFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:avatar)
    end
  end
end
