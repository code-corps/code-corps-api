defmodule CodeCorps.Emails.Transmissions.ProjectApproved do
  import Ecto.Query

  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Project, ProjectUser, Repo, Emails.Recipient, User, WebClient
  }

  @spec build(Project.t) :: %Transmission{}
  def build(%Project{} = project) do
    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: project |> get_owners() |> Enum.map(&Recipient.build/1),
      substitution_data: %{
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        project_title: project.title,
        project_url: project |> preload() |> project_url(),
        subject: "#{project.title} is approved!"
      }
    }
  end

  @spec preload(Project.t) :: Project.t
  defp preload(%Project{} = project), do: project |> Repo.preload(:organization)

  @spec project_url(Project.t) :: String.t
  defp project_url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string()
  end

  @spec get_owners(Project.t) :: list(User.t)
  defp get_owners(%Project{id: project_id}) do
    query = from u in User,
      join: pu in ProjectUser, on: u.id == pu.user_id,
      where: pu.project_id == ^project_id,
      where: pu.role == "owner"

    query |> Repo.all()
  end

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_project_approved_template)
  end
end
