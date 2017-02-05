defmodule CodeCorps.Emails.BaseEmail do
  import Bamboo.Email

  def create do
    new_email()
    |> from("Code Corps<team@codecorps.org>")
  end
end
