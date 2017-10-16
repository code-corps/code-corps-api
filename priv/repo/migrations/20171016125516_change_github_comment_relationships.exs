defmodule CodeCorps.Repo.Migrations.ChangeGithubCommentRelationships do
  use Ecto.Migration

  def up do
    alter table(:comments) do
      remove :github_id
      add :github_comment_id, references(:github_comments)
    end
  end

  def down do
    alter table(:comments) do
      add :github_id, :integer
      remove :github_comment_id
    end
  end
end
