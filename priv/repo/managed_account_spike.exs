alias CodeCorps.Repo
alias CodeCorps.Organization
alias CodeCorps.Project
alias CodeCorps.User
alias CodeCorps.OrganizationMembership

{:ok, owner } =
  %User{}
  |> User.registration_changeset(%{username: "owner", email: "owner@managed.org", password: "password"})
  |> Repo.insert

{:ok, organization } =
  %Organization{}
  |> Organization.create_changeset(%{name: "Managed", description: "A managed organization"})
  |> Repo.insert

{:ok, _} =
  %OrganizationMembership{member_id: owner.id, organization_id: organization.id, role: "owner"}
  |> Repo.insert

{:ok, _project} =
  %Project{}
  |> Project.create_changeset(%{title: "Managed project", description: "A project created for a managed organization", organization_id: organization.id})
  |> Repo.insert

{:ok, _donor} =
  %User{}
  |> User.registration_changeset(%{username: "donor", email: "donor@test.org", password: "password"})
  |> Repo.insert


