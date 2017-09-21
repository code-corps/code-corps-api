defmodule CodeCorps.Repo.Migrations.LoosenMarkdownRestrictions do
  use Ecto.Migration

  def up do
    alter table(:comments) do
      modify :markdown, :text, null: true
    end
  end

  def down do
    alter table(:comments) do
      modify :markdown, :text, null: false
    end
  end
end
