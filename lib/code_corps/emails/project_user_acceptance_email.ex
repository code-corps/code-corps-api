defmodule CodeCorps.Emails.ProjectUserAcceptanceEmail do
  import Bamboo.Email, only: [to: 2]
  import Bamboo.PostmarkHelper

  alias CodeCorps.{Project, ProjectUser, Repo, User, WebClient}
  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.Presenters.ImagePresenter

  @spec create(ProjectUser.t) :: Bamboo.Email.t
  def create(%ProjectUser{project: project, user: user}) do
    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), build_model(project, user))
  end

  @spec build_model(Project.t, User.t) :: map
  defp build_model(%Project{} = project, %User{} = user) do
    %{
      project_logo_url: ImagePresenter.large(project),
      project_title: project.title,
      project_url: project |> preload() |> url(),
      subject: "#{project.title} just added you as a contributor",
      user_first_name: user.first_name,
      user_image_url: ImagePresenter.large(user)
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

  @spec template_id :: String.t
  defp template_id, do: Application.get_env(:code_corps, :postmark_project_user_acceptance_template)
end
