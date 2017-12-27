defmodule CodeCorps.Emails.ProjectApprovedEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test

  alias CodeCorps.Emails.ProjectApprovedEmail

  test "email has the correct data" do
    project = insert(:project)
    %{user: owner1} = insert(:project_user, project: project, role: "owner")
    %{user: owner2} = insert(:project_user, project: project, role: "owner")

    email = ProjectApprovedEmail.create(project)
    assert email.from == "Code Corps<team@codecorps.org>"
    assert Enum.count(email.to) == 2
    assert Enum.member?(email.to, owner1.email)
    assert Enum.member?(email.to, owner2.email)

    template_model = email.private.template_model

    assert template_model == %{
      project_title: project.title,
      project_url: "http://localhost:4200/#{project.organization.slug}/#{project.slug}",
      subject: "#{project.title} is approved!"
    }
  end
end
