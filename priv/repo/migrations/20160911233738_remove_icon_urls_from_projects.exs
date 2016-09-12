defmodule CodeCorps.Repo.Migrations.RemoveIconUrlsFromProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove :icon_large_url
      remove :icon_thumb_url
    end
  end
end
