defmodule CodeCorps.Repo.Migrations.AddCheckConstraintToProjectDescriptionWhenProjectIsApproved do
  use Ecto.Migration

  def change do
    create constraint(:projects, "set_long_description_markdown_if_approved", check: "long_description_markdown IS NOT NULL OR approved = false")
  end
end
