defmodule CodeCorps.Repo.Migrations.AddPartTypeToConversation do
  use Ecto.Migration

  def change do
    alter table(:conversation_parts) do
      add :part_type, :string, default: "comment"
    end
  end
end
