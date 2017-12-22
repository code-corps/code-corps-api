defmodule CodeCorps.SparkPost.Emails.ProjectApprovalRequestTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.SparkPost.Emails.ProjectApprovalRequest

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      project = insert(:project)
      insert(:user, admin: true)

      %{substitution_data: data} = ProjectApprovalRequest.build(project)

      expected_keys =
        "project-approval-request"
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      project = insert(:project)
      admin_1 = insert(:user, admin: true)
      admin_2 = insert(:user, admin: true)

      %{substitution_data: data, recipients: [recipient_1, recipient_2]} =
        ProjectApprovalRequest.build(project)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.admin_project_show_url == "http://localhost:4200/admin/projects/#{project.id}"
      assert data.project_description == project.description
      assert data.project_logo_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png"
      assert data.project_title == project.title
      assert data.project_url == "http://localhost:4200/#{project.organization.slug}/#{project.slug}"
      assert data.subject == "#{project.title} is asking to be approved"

      assert recipient_1.address.email == admin_1.email
      assert recipient_1.address.name == admin_1.first_name
      assert recipient_2.address.email == admin_2.email
      assert recipient_2.address.name == admin_2.first_name
    end
  end
end
