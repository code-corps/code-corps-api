defmodule CodeCorps.StripeAuth do
  use Ecto.Schema

  schema "" do
    field :url, :string, virtual: true
  end

  @doc """
  Generates the URL for a Stripe Connect button for a given project.

  The URL includes a `state` CSRF token which is a Guardian generated
  JWT which contains the project's ID.

  Returns either an `:ok` or `:error` tuple.
  """
  def generate_button_url(project) do
    case Guardian.encode_and_sign(project, :token) do
      {:ok, token, _claims} ->
        url = Stripe.Connect.generate_button_url(token)
        {:ok, url}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
