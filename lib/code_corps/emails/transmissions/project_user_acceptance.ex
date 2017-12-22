defmodule CodeCorps.Emails.Transmissions.ProjectUserAcceptance do
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
  def build(%ProjectUser{project: %Project{} = project, user: %User{} = user}) do
    %Transmission{
      content: %Content.TemplateRef{template_id: template_id()},
      options: %Transmission.Options{inline_css: true},
      recipients: [user |> Recipient.build],
      substitution_data: %{
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        project_logo_url: ImagePresenter.large(project),
        project_title: project.title,
        project_url: project |> preload() |> url(),
        subject: "#{project.title} just added you as a contributor",
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
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string
  end

  @doc ~S"""
  Returns configured template ID for this email
  """
  @spec template_id :: String.t
  def template_id do
    Application.get_env(:code_corps, :sparkpost_project_user_acceptance_template)
  end
end
