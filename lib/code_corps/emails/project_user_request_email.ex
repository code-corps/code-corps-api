defmodule CodeCorps.Emails.ProjectUserRequestEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper
  import Ecto.Query

  alias CodeCorps.{Project, ProjectUser, Repo, User, WebClient}
  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.Presenters.ImagePresenter

  @spec create(ProjectUser.t) :: Bamboo.Email.t
  def create(%ProjectUser{project: project, user: user}) do
    BaseEmail.create
    |> to(project |> get_owners_emails())
    |> template(template_id(), build_model(project, user))
  end

  @spec build_model(Project.t, User.t) :: map
  defp build_model(%Project{} = project, %User{} = user) do
    %{
      contributors_url: project |> preload() |> url(),
      project_logo_url: ImagePresenter.large(project),
      project_title: project.title,
      subject: "#{user.first_name} wants to join #{project.title}",
      user_first_name: user.first_name,
      user_image_url: ImagePresenter.large(user)
    }
  end

  @spec preload(Project.t) :: Project.t
  defp preload(%Project{} = project), do: project |> Repo.preload(:organization)

  @spec url(Project.t) :: String.t
  defp url(project) do
    WebClient.url()
    |> URI.merge(project.organization.slug <> "/" <> project.slug <> "/settings/contributors")
    |> URI.to_string
  end

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_project_request_template)

  @spec get_owners_emails(Project.t) :: list(String.t)
  defp get_owners_emails(%Project{} = project) do
    project |> get_owners() |> Enum.map(&extract_email/1)
  end

  @spec extract_email(User.t) :: String.t
  defp extract_email(%User{email: email}), do: email

  @spec get_owners(Project.t) :: list(User.t)
  defp get_owners(%Project{id: project_id}) do
    query = from u in User,
      join: pu in ProjectUser, on: u.id == pu.user_id,
      where: pu.project_id == ^project_id,
      where: pu.role == "owner"

    query |> Repo.all()
  end
end
