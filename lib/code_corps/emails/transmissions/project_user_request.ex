defmodule CodeCorps.Emails.Transmissions.ProjectUserRequest do
  import Ecto.Query

  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Presenters.ImagePresenter,
    Project,
    ProjectUser,
    Repo,
    Emails.Recipient,
    User,
    WebClient
  }

  @spec build(ProjectUser.t) :: %Transmission{}
  def build(%ProjectUser{project: project, user: user}) do
    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: project |> get_owners() |> Enum.map(&Recipient.build/1),
      substitution_data: %{
        contributors_url: project |> preload() |> url(),
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        project_logo_url: ImagePresenter.large(project),
        project_title: project.title,
        subject: "#{user.first_name} wants to join #{project.title}",
        user_first_name: user.first_name,
        user_image_url: ImagePresenter.large(user)
      }
    }
  end

  @spec preload(Project.t) :: Project.t
  defp preload(%Project{} = project), do: project |> Repo.preload(:organization)

  @spec url(Project.t) :: String.t
  defp url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug <> "/people")
    |> URI.to_string
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
    Application.get_env(:code_corps, :sparkpost_project_user_request_template)
  end
end
