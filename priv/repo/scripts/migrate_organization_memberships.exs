defmodule CodeCorps.Repo.Scripts.MigrateOrganizations do
  require Logger

  alias CodeCorps.{OrganizationMembership, Project, ProjectUser, Repo, User}

  def run do
    OrganizationMembership
    |> Repo.all()
    |> Repo.preload([:member, {:organization, :projects}])
    |> Enum.map(&migrate_member/1)
    |> aggregate_results
    |> log
  end

  defp migrate_member(%OrganizationMembership{
      member: user,
      organization: %{projects: [project]},
      role: role
  }) do
    create_membership(project, user, role)
  end

  defp create_membership(%Project{id: project_id}, %User{id: user_id}, role) do
    %ProjectUser{} |> build_changeset(project_id, user_id, role) |> Repo.insert()
  end

  defp build_changeset(struct, project_id, user_id, role) do
    attrs = %{project_id: project_id, user_id: user_id, role: role}
    struct
    |> Ecto.Changeset.cast(attrs, [:project_id, :user_id, :role])
    |> Ecto.Changeset.unique_constraint(:project, name: :project_users_user_id_project_id_index)
  end

  defp aggregate_results(results) do
    passing_count = Enum.count(results, fn({status, _}) -> status == :ok end)
    error_count = Enum.count(results, fn({status, _}) -> status == :error end)
    {passing_count, error_count}
  end

  defp log({passing_count, error_count}) do
    Logger.info("#{passing_count} memberships migrated, #{error_count} errors.")
  end
end

CodeCorps.Repo.Scripts.MigrateOrganizations.run()
