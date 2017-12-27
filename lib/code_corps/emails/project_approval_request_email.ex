defmodule CodeCorps.Emails.ProjectApprovalRequestEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper
  import Ecto.Query, only: [where: 3]

  alias CodeCorps.{Project, Repo, User, WebClient}
  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.Presenters.ImagePresenter

  @spec create(Project.t) :: Bamboo.Email.t
  def create(%Project{} = project) do
    BaseEmail.create
    |> to(get_site_admins_emails())
    |> template(template_id(), build_model(project))
  end

  @spec build_model(Project.t) :: map
  defp build_model(%Project{} = project) do
    %{
      admin_project_show_url: project |> admin_url(),
      project_description: project.description,
      project_logo_url: ImagePresenter.large(project),
      project_title: project.title,
      project_url: project |> preload() |> project_url(),
      subject: "#{project.title} is asking to be approved"
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

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_project_approval_request_template)

  @spec get_site_admins_emails() :: list(String.t)
  defp get_site_admins_emails() do
    get_site_admins() |> Enum.map(&extract_email/1)
  end

  @spec extract_email(User.t) :: String.t
  defp extract_email(%User{email: email}), do: email

  @spec get_site_admins() :: list(User.t)
  defp get_site_admins() do
    User
    |> where([object], object.admin == true)
    |> Repo.all()
  end
end
