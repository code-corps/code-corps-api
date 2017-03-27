defmodule CodeCorps.Emails.ProjectUserAcceptanceEmail do
  import Bamboo.Email
  import Bamboo.PostmarkHelper

  alias CodeCorps.{Project, ProjectUser, Repo, User}
  alias CodeCorps.Emails.BaseEmail
  alias CodeCorps.Presenters.ImagePresenter

  def create(%ProjectUser{project: project, user: user}) do
    BaseEmail.create
    |> to(user.email)
    |> template(template_id(), build_model(project, user))
  end

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

  defp preload(%Project{} = project), do: project |> Repo.preload(:organization)

  defp url(project) do
    Application.get_env(:code_corps, :site_url)
    |> URI.merge(project.organization.slug <> "/" <> project.slug)
    |> URI.to_string
  end

  defp template_id, do: Application.get_env(:code_corps, :postmark_project_acceptance_template)
end
