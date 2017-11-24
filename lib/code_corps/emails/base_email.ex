defmodule CodeCorps.Emails.BaseEmail do
  import Bamboo.Email, only: [from: 2, new_email: 0]

  @spec create :: Bamboo.Email.t
  def create do
    new_email()
    |> from("Code Corps<team@codecorps.org>")
  end
end
