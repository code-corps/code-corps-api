defmodule CodeCorps.Validators.SlugValidator do
  @moduledoc """
  Used for validating slug fields in a given changeset.
  """

  alias Ecto.Changeset

  @doc """
  Validates a slug.

  Matches slugs with:
  - only letters
  - prefixed/suffixed underscores
  - prefixed/suffixed numbers
  - single inside dashes
  - single/multiple inside underscores
  - one character

  Prevents slugs with:
  - prefixed symbols
  - prefixed/suffixed dashes
  - multiple consecutive dashes
  - single/multiple/multiple consecutive slashes

  Also prevents slugs that conflict with reserved routes for either the API or the web.
  """
  def validate_slug(changeset, field_name) do
    valid_slug_pattern = ~r/\A((?:(?:(?:[^-\W]-?))*)(?:(?:(?:[^-\W]-?))*)\w+)\z/

    # Routes for the API – api. subdomain
    api_routes = ~w(
      api
      categories comments contributors
      images issues
      mentions
      notifications
      oauth oauth_clients organizations organization-memberships
      ping projects project-categories
      project-skills
      repositories roles
      skills slugged-route stars
      tags tasks task-images task-likes
      teams token tokens
      user-roles user-skills user users
    )

    # Routes for the web – www. subdomain
    web_routes = ~w(
      about account admin android app apps
      blog
      charter contact cookies
      developer developers discover donate
      engineering enterprise explore
      facebook favorites feed followers following
      github
      help home
      integrations invite invitations ios
      jobs
      learn likes lists log-in log-out login logout
      news notifications
      popular press pricing privacy projects
      search security session sessions settings shop showcases
      sign-in sign-out signin signout signup sitemap spotlight start
      team terms training trends trust tour twitter
      watching
      year
    )

    reserved_routes = api_routes ++ web_routes

    changeset
    |> Changeset.validate_format(field_name, valid_slug_pattern)
    |> Changeset.validate_exclusion(field_name, reserved_routes)
  end
end
