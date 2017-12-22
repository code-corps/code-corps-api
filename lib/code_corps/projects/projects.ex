defmodule CodeCorps.Projects do
  @moduledoc """
  Work with `CodeCorps.Projects`.
  """

  import CodeCorpsWeb.ProjectController, only: [preload: 1]

  alias CodeCorps.{
    Analytics.SegmentTracker, Project, Repo, SparkPost, User
  }
  alias Ecto.Changeset

  @doc """
  Create a project.
  """
  @spec create(map, User.t) :: {:ok, Project.t} | {:error, Changeset.t}
  def create(%{} = params, %User{} = user) do
    with {:ok, %Project{} = project} <- %Project{} |> Project.create_changeset(params) |> Repo.insert(),
         project <- preload(project) do

      user |> track_created(project)

      {:ok, project}
    end
  end

  @doc """
  Update a project.
  """
  @spec update(Project.t, map, User.t) :: {:ok, Project.t} | {:error, Changeset.t}
  def update(%Project{} = project, %{} = params, %User{} = user) do
    with {:ok, %Project{} = updated_project} <- project |> Project.update_changeset(params) |> Repo.update(),
         updated_project <- preload(updated_project) do

      maybe_send_approval_request_email(updated_project, project)
      maybe_send_approved_email(updated_project, project)

      user |> track_updated(updated_project)
      user |> maybe_track_approved(updated_project, project)
      user |> maybe_track_approval_requested(updated_project, project)

      {:ok, updated_project}
    end
  end

  @spec track_created(User.t, Project.t) :: any
  defp track_created(%User{id: user_id}, %Project{} = project) do
    user_id |> SegmentTracker.track("Created Project", project)
  end

  @spec track_updated(User.t, Project.t) :: any
  defp track_updated(%User{id: user_id}, %Project{} = project) do
    user_id |> SegmentTracker.track("Updated Project", project)
  end

  @spec maybe_track_approval_requested(User.t, Project.t, Project.t) :: any
  defp maybe_track_approval_requested(
    %User{id: user_id},
    %Project{approval_requested: true} = updated_project,
    %Project{approval_requested: false}) do

    user_id |> SegmentTracker.track("Requested Project Approval", updated_project)
  end
  defp maybe_track_approval_requested(%User{}, %Project{}, %Project{}), do: :nothing

  @spec maybe_track_approved(User.t, Project.t, Project.t) :: any
  defp maybe_track_approved(
    %User{id: user_id},
    %Project{approved: true} = updated_project,
    %Project{approved: false}) do

    user_id |> SegmentTracker.track("Approved Project", updated_project)
  end
  defp maybe_track_approved(%User{}, %Project{}, %Project{}), do: :nothing

  @spec maybe_send_approval_request_email(Project.t, Project.t) :: any
  defp maybe_send_approval_request_email(
    %Project{approval_requested: true} = updated_project,
    %Project{approval_requested: false}) do
    send_approval_request_email(updated_project)
  end
  defp maybe_send_approval_request_email(%Project{}, %Project{}), do: :nothing

  @spec send_approval_request_email(Project.t) :: tuple
  defp send_approval_request_email(project) do
    project
    |> preload()
    |> SparkPost.send_project_approval_request_email()
  end

  @spec maybe_send_approved_email(Project.t, Project.t) :: any
  defp maybe_send_approved_email(
    %Project{approved: true} = updated_project,
    %Project{approved: false}) do
    send_approved_email(updated_project)
  end
  defp maybe_send_approved_email(%Project{}, %Project{}), do: :nothing

  @spec send_approved_email(Project.t) :: tuple
  defp send_approved_email(project) do
    project
    |> preload()
    |> SparkPost.send_project_approved_email()
  end
end
