defmodule CodeCorps.Repo.Migrations.AddConversationModels do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :status, :string, null: false, default: "open"
      add :read_at, :utc_datetime, null: true
      add :message_id, references(:messages)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:conversations, [:status])
    create index(:conversations, [:message_id])
    create index(:conversations, [:user_id])

    create table(:conversation_parts) do
      add :body, :text, null: false
      add :read_at, :utc_datetime, null: true
      add :author_id, references(:users)
      add :conversation_id, references(:conversations)

      timestamps()
    end

    create index(:conversation_parts, [:author_id])
    create index(:conversation_parts, [:conversation_id])
  end
end
