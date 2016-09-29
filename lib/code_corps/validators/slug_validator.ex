defmodule CodeCorps.Validators.SlugValidator do
  @moduledoc """
  Used for validating slug fields in a given changeset.
  """

  alias Ecto.Changeset

  def validate_slug(changeset, field_name) do
    # Matches slugs with:
    # - only letters
    # - prefixed/suffixed underscores
    # - prefixed/suffixed numbers
    # - single inside dashes
    # - single/multiple inside underscores
    # - one character
    #
    # Prevents slugs with:
    # - prefixed symbols
    # - prefixed/suffixed dashes
    # - multiple consecutive dashes
    # - single/multiple/multiple consecutive slashes
    valid_slug_pattern = ~r/\A((?:(?:(?:[^-\W]-?))*)(?:(?:(?:[^-\W]-?))*)\w+)\z/

    # Prevents slugs that conflict with reserved routes
    reserved_routes = ~w(
      about account admin android api app apps blog bug bugs cache charter
      comment comments contact contributor contributors cookies
      developer developers discover donate engineering enterprise explore
      facebook favorites feed followers following github help home image images
      integration integrations invite invitations ios issue issues jobs learn
      likes lists log-in log-out login logout mention mentions new news
      notification notifications oauth oauth_clients organization organizations
      ping popular task-image task-images task-like task-likes task
      press pricing privacy
      project projects repositories role roles rules search security session
      sessions settings shop showcases sidekiq sign-in sign-out signin signout
      signup sitemap slug slugs spotlight stars status tag tags
      tasks team teams terms training trends trust tour twitter
      user-role user-roles user-skill user-skills user users watching year
    )

    changeset
    |> Changeset.validate_format(field_name, valid_slug_pattern)
    |> Changeset.validate_exclusion(field_name, reserved_routes)
  end
end
