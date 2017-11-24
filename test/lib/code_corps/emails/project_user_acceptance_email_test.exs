defmodule CodeCorps.Emails.ProjectUserAcceptanceEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.Emails.ProjectUserAcceptanceEmail

  test "acceptance email works" do
    %{project: project, user: user} = project_user = insert(:project_user)

    email = ProjectUserAcceptanceEmail.create(project_user)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert email.to == user.email

    template_model = email.private.template_model

    assert template_model == %{
      project_title: project.title,
      project_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}",
      project_logo_url: "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png",
      user_image_url: "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_large_.png",
      user_first_name: user.first_name,
      subject: "#{project.title} just added you as a contributor"
    }
  end
end
