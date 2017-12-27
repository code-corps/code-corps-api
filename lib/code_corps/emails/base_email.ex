defmodule CodeCorps.Emails.BaseEmail do
  import Bamboo.Email, only: [from: 2, new_email: 0]
  alias CodeCorps.User

  @spec create :: Bamboo.Email.t
  def create do
    new_email()
    |> from("Code Corps<team@codecorps.org>")
  end

  @spec get_name(User.t) :: String.t
  def get_name(%User{first_name: nil}), do: "there"
  def get_name(%User{first_name: name}), do: name
end
