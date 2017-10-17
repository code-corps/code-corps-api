defmodule CodeCorps.WebClient do
  @moduledoc ~S"""
  Confirms URLs for the web client app routes
  """
  alias CodeCorps.{
    Comment,
    Organization,
    Project,
    Task,
    User
  }

  @doc ~S"""
  Returns the web client site root URL
  """
  @spec url :: String.t
  def url, do: Application.get_env(:code_corps, :site_url)

  @doc ~S"""
  Return the web client site url for the specified record
  """
  @spec url(User.t | Organization.t | Project.t | Task.t | Comment.t) :: String.t
  def url(%User{username: username}), do: url() <> "/" <> username
  def url(%Organization{slug: slug}), do: url() <> "/" <> slug
  def url(%Project{slug: slug, organization: %Organization{} = organization}) do
    (organization |> url()) <> "/" <> slug
  end
  def url(%Task{project: %Project{} = project, number: number}) do
    (project |> url()) <> "/" <> (number |> Integer.to_string)
  end
  def url(%Comment{task: %Task{} = task}), do: task |> url()
end
