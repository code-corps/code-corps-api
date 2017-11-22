defmodule CodeCorps.GithubIssueAssignee do
  use Ecto.Schema
  import Ecto.Changeset


  schema "github_issue_assignees" do
    belongs_to :github_issue, CodeCorps.GithubIssue
    belongs_to :github_user, CodeCorps.GithubUser

    timestamps()
  end

  @doc false
  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:github_issue_id, :github_user_id])
    |> validate_required([:github_issue_id, :github_user_id])
    |> assoc_constraint(:github_issue)
    |> assoc_constraint(:github_user)
    |> unique_constraint(:github_user, name: :github_issue_assignees_github_issue_id_github_user_id_index)
  end
end
