defmodule CodeCorps.Github.JWT do
  @moduledoc """
  In charge of loading a a GitHub app .pem and generating a JSON Web Token from
  it.
  """

  @doc """
  Generates a JWT from the GitHub App's generated RSA private key using the
  RS256 algo, where the issuer is the GitHub App's ID.

  Used to exchange the JWT for an access token for a given integration, or
  for the GitHub App itself.

  Expires in 5 minutes.
  """
  def generate do
    signer = rsa_key() |> Joken.rs256()

    %{}
    |> Joken.token
    |> Joken.with_exp(Timex.now |> Timex.shift(minutes: 5) |> Timex.to_unix)
    |> Joken.with_iss(app_id())
    |> Joken.with_iat(Timex.now |> Timex.to_unix)
    |> Joken.with_signer(signer)
    |> Joken.sign
    |> Joken.get_compact
  end

  defp rsa_key do
    Application.get_env(:code_corps, :github_app_pem)
    |> JOSE.JWK.from_pem()
  end

  defp app_id(), do: Application.get_env(:code_corps, :github_app_id)
end
