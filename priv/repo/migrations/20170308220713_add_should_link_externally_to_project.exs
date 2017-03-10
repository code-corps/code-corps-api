defmodule CodeCorps.Repo.Migrations.AddShouldLinkExternallyToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :should_link_externally, :boolean, default: false
    end
  end
end
