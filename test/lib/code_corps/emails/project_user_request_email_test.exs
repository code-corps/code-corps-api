defmodule CodeCorps.Emails.ProjectUserRequestEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.Emails.ProjectUserRequestEmail

  test "request email works" do
    project = insert(:project)
    %{user: requesting_user} = project_user = insert(:project_user, project: project)
    %{user: owner1} = insert(:project_user, project: project, role: "owner")
    %{user: owner2} = insert(:project_user, project: project, role: "owner")

    email = ProjectUserRequestEmail.create(project_user)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert Enum.count(email.to) == 2
    assert Enum.member?(email.to, owner1.email)
    assert Enum.member?(email.to, owner2.email)

    template_model = email.private.template_model

    assert template_model == %{
      contributors_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}/people",
      project_title: project.title,
      project_logo_url: "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png",
      user_image_url: "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_large_.png",
      user_first_name: requesting_user.first_name,
      subject: "#{requesting_user.first_name} wants to join #{project.title}"
    }
  end
end
