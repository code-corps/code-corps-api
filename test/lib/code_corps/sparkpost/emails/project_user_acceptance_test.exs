defmodule CodeCorps.SparkPost.Emails.ProjectUserAcceptanceTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.SparkPost.Emails.ProjectUserAcceptance

  test "has a template_id assigned" do
    assert ProjectUserAcceptance.template_id
  end

  describe "build/1" do
    test "provides substitution data for all keys used by template" do
      project_user = insert(:project_user)

      %{substitution_data: data} = ProjectUserAcceptance.build(project_user)

      expected_keys =
        ProjectUserAcceptance.template_id
        |> CodeCorps.SparkPostHelpers.get_keys_used_by_template
      assert data |> Map.keys == expected_keys
    end

    test "builds correct transmission model" do
      %{project: project, user: user} = project_user = insert(:project_user)

      %{substitution_data: data, recipients: [recipient]} =
        ProjectUserAcceptance.build(project_user)

      assert data.from_name == "Code Corps"
      assert data.from_email == "team@codecorps.org"

      assert data.project_title == project.title
      assert data.project_url == "http://localhost:4200/#{project.organization.slug}/#{project.slug}"
      assert data.project_logo_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/project_default_large_.png"
      assert data.user_image_url == "#{Application.get_env(:code_corps, :asset_host)}/icons/user_default_large_.png"
      assert data.user_first_name == user.first_name
      assert data.subject == "#{project.title} just added you as a contributor"

      assert recipient.address.email == user.email
      assert recipient.address.name == user.first_name
    end
  end
end
