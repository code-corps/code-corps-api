defmodule CodeCorps.Repo.Seeds.ImageMigration do
  alias CodeCorps.Organization
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.User

  @icon_color_generator Application.get_env(:code_corps, :icon_color_generator)

  def migrate() do
    Organization
    |> Repo.all()
    |> Enum.each(&handle_organization_migration/1)

    Project
    |> Repo.all()
    |> Enum.each(&handle_project_migration/1)

    User
    |> Repo.all()
    |> Enum.each(&handle_user_migration/1)
  end

  defp handle_organization_migration(organization) do
    cond do
      organization.cloudinary_public_id != nil ->
        IO.puts "Cloudinary image already exists for #{organization.name}, skipping migration."
      organization.icon == nil ->
        IO.puts "No icon exists for #{organization.name}, generating color only."
        color = @icon_color_generator.generate
        {:ok, organization} =
          Organization.changeset(organization, %{default_color: color})
          |> Repo.update
      true ->
        IO.puts "Migrating image from S3 to Cloudinary for #{organization.name}."

        color = @icon_color_generator.generate

        original_image_url = CodeCorps.OrganizationIcon.url({organization.icon, organization}, :original)

        [ok: %Cloudex.UploadedImage{public_id: public_id}] =
          original_image_url
          |> Cloudex.upload()

        {:ok, organization} =
          Organization.changeset(organization, %{cloudinary_public_id: public_id, default_color: color})
          |> Repo.update
    end
  end

  defp handle_project_migration(project) do
    cond do
      project.cloudinary_public_id != nil ->
        IO.puts "Cloudinary image already exists for #{project.title}, skipping migration."
      project.icon == nil ->
        IO.puts "No icon exists for #{project.title}, generating color only."
        color = @icon_color_generator.generate
        {:ok, project} =
          Project.changeset(project, %{default_color: color})
          |> Repo.update
      true ->
        IO.puts "Migrating image from S3 to Cloudinary for #{project.title}."

        color = @icon_color_generator.generate

        original_image_url = CodeCorps.ProjectIcon.url({project.icon, project}, :original)

        [ok: %Cloudex.UploadedImage{public_id: public_id}] =
          original_image_url
          |> Cloudex.upload()

        {:ok, project} =
          Project.changeset(project, %{cloudinary_public_id: public_id, default_color: color})
          |> Repo.update
    end
  end

  defp handle_user_migration(user) do
    cond do
      user.cloudinary_public_id != nil ->
        IO.puts "Cloudinary image already exists for #{user.username}, skipping migration."
      user.photo == nil ->
        IO.puts "No photo exists for #{user.username}, generating color only."
        color = @icon_color_generator.generate
        {:ok, user} =
          User.changeset(user, %{default_color: color})
          |> Repo.update
      true ->
        IO.puts "Migrating image from S3 to Cloudinary for #{user.username}."

        color = @icon_color_generator.generate

        original_image_url = CodeCorps.UserPhoto.url({user.photo, user}, :original)

        [ok: %Cloudex.UploadedImage{public_id: public_id}] =
          original_image_url
          |> Cloudex.upload()

        {:ok, user} =
          User.changeset(user, %{cloudinary_public_id: public_id, default_color: color})
          |> Repo.update
    end
  end
end

CodeCorps.Repo.Seeds.ImageMigration.migrate()
