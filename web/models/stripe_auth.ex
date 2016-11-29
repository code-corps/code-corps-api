defmodule CodeCorps.StripeAuth do
  @moduledoc """
  Provides a virtual resource for data needed for Stripe Connect OAuth flows.
  """

  use Ecto.Schema

  alias CodeCorps.Organization
  alias CodeCorps.Project

  schema "" do
    field :url, :string, virtual: true
  end

  @doc """
  Generates the URL for a Stripe Connect button for a given project.

  The URL includes a `state` CSRF token which is a Guardian generated
  JWT which contains the project's ID.

  Returns either an `:ok` or `:error` tuple.
  """
  def authorize_url(user, %Project{organization: %Organization{} = organization} = project) do
    case Guardian.encode_and_sign(project, :token) do
      {:ok, token, _claims} ->
        url =
          organization
          |> url_params(user, token)
          |> Stripe.Connect.OAuth.authorize_url()
        {:ok, url}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp url_params(organization, user, token) do
    %{
      state: token,
      stripe_user: %{
        "business_name" => organization.name,
        "email" => user.email,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "product_category" => "software",
        "product_description" => organization.name <> " accepts donations on the Code Corps platform in order to build and sustain open source software for public good. Donations usually happen once a month, although the frequency may vary.",
        "url" => "https://www.codecorps.org/" <> organization.slug
      }
    }
  end
end
