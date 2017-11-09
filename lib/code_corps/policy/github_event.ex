defmodule CodeCorps.Policy.GithubEvent do
  alias CodeCorps.User

  def index?(%User{admin: true}), do: true
  def index?(%User{admin: false}), do: false

  def show?(%User{admin: true}), do: true
  def show?(%User{admin: false}), do: false
end
