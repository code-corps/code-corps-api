defmodule CodeCorps.Emails.ProjectApprovalRequestEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.Emails.ProjectApprovalRequestEmail

  test "request email works" do
    project = insert(:project)
    admin1 = insert(:user, admin: true)
    admin2 = insert(:user, admin: true)

    email = ProjectApprovalRequestEmail.create(project)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert Enum.count(email.to) == 2
    assert Enum.member?(email.to, admin1.email)
    assert Enum.member?(email.to, admin2.email)

    template_model = email.private.template_model

    assert template_model == %{
      admin_project_show_url: "http://localhost:4200/admin/projects/#{project.id}",
      project_description: project.description,
      project_logo_url: "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png",
      project_title: project.title,
      project_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}",
      subject: "#{project.title} is asking to be approved"
    }
  end
end
