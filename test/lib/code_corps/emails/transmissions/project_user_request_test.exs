defmodule CodeCorps.Emails.Transmissions.ProjectUserRequestTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.Emails.Transmissions.ProjectUserRequest

  test "has a template_id assigned" do
    assert ProjectUserRequest.template_id
  end

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      project = insert(:project)
      project_user = insert(:project_user, project: project)

      %{substitution_data: data} = ProjectUserRequest.build(project_user)

      expected_keys =
        ProjectUserRequest.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      project = insert(:project)
      %{user: requesting_user} = project_user = insert(:project_user, project: project)
      %{user: owner_1} = insert(:project_user, project: project, role: "owner")
      %{user: owner_2} = insert(:project_user, project: project, role: "owner")

      %{substitution_data: data, recipients: recipients} =
        ProjectUserRequest.build(project_user)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.contributors_url == "http://localhost:4200/#{project.organization.slug}/#{project.slug}/people"
      assert data.project_title == project.title
      assert data.project_logo_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png"
      assert data.user_image_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_large_.png"
      assert data.user_first_name == requesting_user.first_name
      assert data.subject == "#{requesting_user.first_name} wants to join #{project.title}"

      assert %{address: %{email: owner_1.email, name: owner_1.first_name}} in recipients
      assert %{address: %{email: owner_2.email, name: owner_2.first_name}} in recipients
    end
  end
end
