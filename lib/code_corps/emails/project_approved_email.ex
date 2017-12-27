defmodule CodeCorps.Emails.ProjectApprovedEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper
  import Ecto.Query

  alias CodeCorps.{Project, ProjectUser, Repo, User, WebClient}
  alias CodeCorps.Emails.BaseEmail

  @spec create(Project.t) :: Bamboo.Email.t
  def create(%Project{} = project) do
    BaseEmail.create
    |> to(project |> get_owners_emails())
    |> template(template_id(), build_model(project))
  end

  @spec build_model(Project.t) :: map
  defp build_model(%Project{} = project) do
    %{
      project_title: project.title,
      project_url: project |> preload() |> project_url(),
      subject: "#{project.title} is approved!"
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

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_project_approved_template)

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
