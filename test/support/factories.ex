defmodule CodeCorps.Factories do
  # with Ecto
  use ExMachina.Ecto, repo: CodeCorps.Repo

  def user_factory do
    %CodeCorps.User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "password"
    }
  end

  def organization_factory do
    %CodeCorps.Organization{
      name: sequence(:username, &"Organization #{&1}"),
      description: sequence(:email, &"Description of organization #{&1}"),
    }
  end

  def organization_membership_factory do
    %CodeCorps.OrganizationMembership{
      member: build(:user),
      organization: build(:organization),
      role: "contributor"
    }
  end
end
