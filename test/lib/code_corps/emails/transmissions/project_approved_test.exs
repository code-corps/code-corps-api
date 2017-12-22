defmodule CodeCorps.Emails.Transmissions.ProjectApprovedTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.Emails.Transmissions.ProjectApproved

  test "has a template_id assigned" do
    assert ProjectApproved.template_id
  end

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      project = insert(:project)

      %{substitution_data: data} = ProjectApproved.build(project)

      expected_keys =
        ProjectApproved.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      project = insert(:project)
      %{user: owner_1} = insert(:project_user, project: project, role: "owner")
      %{user: owner_2} = insert(:project_user, project: project, role: "owner")

      %{substitution_data: data, recipients: recipients} =
        ProjectApproved.build(project)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.project_title == project.title
      assert data.project_url == "http://localhost:4200/#{project.organization.slug}/#{project.slug}"
      assert data.subject == "#{project.title} is approved!"

      assert %{address: %{email: owner_1.email, name: owner_1.first_name}} in recipients
      assert %{address: %{email: owner_2.email, name: owner_2.first_name}} in recipients
    end
  end
end
