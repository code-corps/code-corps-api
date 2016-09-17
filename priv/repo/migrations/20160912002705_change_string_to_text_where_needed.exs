defmodule CodeCorps.Repo.Migrations.ChangeStringToTextWhereNeeded do
  use Ecto.Migration

  def up do
    alter table(:categories) do
      modify :description, :text
    end

    alter table(:organizations) do
      modify :name, :text
      modify :description, :text
    end

    alter table(:posts) do
      modify :body, :text
      modify :markdown, :text
      modify :title, :text
    end

    alter table(:projects) do
      modify :description, :text
      modify :long_description_body, :text
      modify :long_description_markdown, :text
    end

    alter table(:skills) do
      modify :description, :text
    end

    alter table(:users) do
      modify :biography, :text
    end
  end

  def down do
    alter table(:categories) do
      modify :description, :string
    end

    alter table(:organizations) do
      modify :name, :string
      modify :description, :string
    end

    alter table(:posts) do
      modify :body, :string
      modify :markdown, :string
      modify :title, :string
    end

    alter table(:projects) do
      modify :description, :string
      modify :long_description_body, :string
      modify :long_description_markdown, :string
    end

    alter table(:skills) do
      modify :description, :string
    end

    alter table(:users) do
      modify :biography, :string
    end
  end
end
