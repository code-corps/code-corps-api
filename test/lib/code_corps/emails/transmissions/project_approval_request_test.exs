defmodule CodeCorps.Emails.Transmissions.ProjectApprovalRequestTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.Emails.Transmissions.ProjectApprovalRequest

  test "has a template_id assigned" do
    assert ProjectApprovalRequest.template_id
  end

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      project = insert(:project)
      insert(:user, admin: true)

      %{substitution_data: data} = ProjectApprovalRequest.build(project)

      expected_keys =
        ProjectApprovalRequest.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      project = insert(:project)
      admin_1 = insert(:user, admin: true)
      admin_2 = insert(:user, admin: true)

      %{substitution_data: data, recipients: recipients} =
        ProjectApprovalRequest.build(project)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.admin_project_show_url == "http://localhost:4200/admin/projects/#{project.id}"
      assert data.project_description == project.description
      assert data.project_logo_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png"
      assert data.project_title == project.title
      assert data.project_url == "http://localhost:4200/#{project.organization.slug}/#{project.slug}"
      assert data.subject == "#{project.title} is asking to be approved"

      assert %{address: %{email: admin_1.email, name: admin_1.first_name}} in recipients
      assert %{address: %{email: admin_2.email, name: admin_2.first_name}} in recipients
    end
  end
end
