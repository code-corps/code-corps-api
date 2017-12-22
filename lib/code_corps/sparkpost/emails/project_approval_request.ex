defmodule CodeCorps.SparkPost.Emails.ProjectApprovalRequest do
  import Ecto.Query, only: [where: 3]

  alias SparkPost.{Content, Transmission}
  alias CodeCorps.{
    Presenters.ImagePresenter,
    Project,
    Repo,
    SparkPost.Emails.Recipient,
    User,
    WebClient
  }

  @spec build(Project.t) :: %Transmission{}
  def build(%Project{} = project) do
    %Transmission{
      content: %Content.TemplateRef{template_id: "project-approval-request"},
      options: %Transmission.Options{inline_css: true},
      recipients: get_site_admins() |> Enum.map(&Recipient.build/1),
      substitution_data: %{
        admin_project_show_url: project |> admin_url(),
        from_name: "Code Corps",
        from_email: "team@codecorps.org",
        project_description: project.description,
        project_logo_url: ImagePresenter.large(project),
        project_title: project.title,
        project_url: project |> preload() |> project_url(),
        subject: "#{project.title} is asking to be approved"
      }
    }
  end

  @spec preload(Project.t) :: Project.t
  defp preload(%Project{} = project), do: project |> Repo.preload(:organization)

  @spec admin_url(Project.t) :: String.t
  defp admin_url(project) do
    WebClient.url()
    |> URI.merge("/admin/projects/" <> Integer.to_string(project.id))
    |> URI.to_string()
  end

  @spec project_url(Project.t) :: String.t
  defp project_url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string()
  end

  @spec get_site_admins() :: list(User.t)
  defp get_site_admins() do
    User
    |> where([object], object.admin == true)
    |> Repo.all()
  end
end
