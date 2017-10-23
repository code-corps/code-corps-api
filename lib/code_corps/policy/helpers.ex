defmodule CodeCorps.Policy.Helpers do
  @moduledoc """
  Holds helpers for extracting record relationships and determining roles for
  authorization policies.
  """

  alias CodeCorps.{
    Organization, ProjectUser,
    Project, ProjectUser, Repo,
    TaskSkill, Task, User, UserTask
  }
  alias Ecto.Changeset

  @doc """
  Determines if the provided organization or project is owned by the provided user
  """
  @spec owned_by?(nil | Organization.t | Project.t, User.t) :: boolean
  def owned_by?(%Organization{owner_id: owner_id}, %User{id: user_id}),
    do: owner_id == user_id
  def owned_by?(%Project{} = project, %User{} = user),
    do: project |> get_membership(user) |> get_role |> owner?
  def owned_by?(nil, _), do: false

  @doc """
  Determines if the provided project is being administered by the provided User

  Returns `true` if the user is an admin or higher member of the project
  """
  @spec administered_by?(nil | Project.t, User.t) :: boolean
  def administered_by?(%Project{} = project, %User{} = user),
    do: project |> get_membership(user) |> get_role |> admin_or_higher?
  def administered_by?(nil, _), do: false

  @doc """
  Determines if the provided project is being contributed to by the provided User

  Returns `true` if the user is a contributor or higher member of the project
  """
  @spec contributed_by?(nil | Project.t, User.t) :: boolean
  def contributed_by?(%Project{} = project, %User{} = user),
    do: project |> get_membership(user) |> get_role |> contributor_or_higher?
  def contributed_by?(nil, _), do: false

  @doc """
  Retrieves an organization record, from a model struct, or an `Ecto.Changeset`
  containing an `organization_id` field

  Returns `CodeCorps.Organization`
  """
  @spec get_organization(struct | Changeset.t | any) :: Organization.t
  def get_organization(%{"organization_id" => id}), do: Organization |> Repo.get(id)
  def get_organization(%{organization_id: id}), do: Organization |> Repo.get(id)
  def get_organization(%Changeset{changes: %{organization_id: id}}), do: Organization |> Repo.get(id)
  def get_organization(_), do: nil

  @doc """
  Retrieves a project record, from a model struct, or an `Ecto.Changeset`
  containing a `project_id` field

  Returns `CodeCorps.Project`
  """
  @spec get_project(struct | Changeset.t | any) :: Project.t
  def get_project(%{"project_id" =>  id}), do: Project |> Repo.get(id)
  def get_project(%{project_id: id}), do: Project |> Repo.get(id)
  def get_project(%Changeset{changes: %{project_id: id}}), do: Project |> Repo.get(id)
  def get_project(_), do: nil

  @doc """
  Retrieves the role field from a `CodeCorps.ProjectUser` struct or an `Ecto.Changeset`
  """
  @spec get_role(nil | ProjectUser.t | Changeset.t) :: String.t | nil
  def get_role(nil), do: nil
  def get_role(%ProjectUser{role: role}), do: role
  def get_role(%Changeset{} = changeset), do: changeset |> Changeset.get_field(:role)

  @spec admin_or_higher?(String.t) :: boolean
  defp admin_or_higher?(role) when role in ["admin", "owner"], do: true
  defp admin_or_higher?(_), do: false

  @spec contributor_or_higher?(String.t) :: boolean
  defp contributor_or_higher?(role) when role in ["contributor", "admin", "owner"], do: true
  defp contributor_or_higher?(_), do: false

  @spec owner?(String.t) :: boolean
  defp owner?("owner"), do: true
  defp owner?(_), do: false

  @doc """
  Retrieves task from associated record
  """
  @spec get_task(Changeset.t | TaskSkill.t | UserTask.t | map) :: Task.t
  def get_task(%TaskSkill{task_id: task_id}), do: Repo.get(Task, task_id)
  def get_task(%UserTask{task_id: task_id}), do: Repo.get(Task, task_id)
  def get_task(%{"task_id" => task_id}), do: Repo.get(Task, task_id)
  def get_task(%Changeset{changes: %{task_id: task_id}}), do: Repo.get(Task, task_id)

  @doc """
  Determines if the provided task was authored by the provided user
  """
  @spec task_authored_by?(Task.t, User.t) :: boolean
  def task_authored_by?(%Task{user_id: author_id}, %User{id: user_id}), do: user_id == author_id

  # Returns `CodeCorps.ProjectUser` for specified `CodeCorps.Project`
  # and `CodeCorps.User`, or nil
  @spec get_membership(Project.t, User.t) :: nil | ProjectUser.t
  defp get_membership(%Project{id: project_id}, %User{id: user_id}),
    do: ProjectUser |> Repo.get_by(project_id: project_id, user_id: user_id)
end
