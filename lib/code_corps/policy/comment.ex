defmodule CodeCorps.Policy.Comment do
  @moduledoc ~S"""
  Authorization policies for performing actions on `Comment` records
  """
  alias CodeCorps.{Comment, User}

  def create?(%User{id: user_id}, %{"user_id" => author_id})
    when user_id == author_id and not is_nil(user_id), do: true
  def create?(%User{}, %{}), do: false

  def update?(%User{id: user_id}, %Comment{user_id: author_id})
    when user_id == author_id and not is_nil(user_id), do: true
  def update?(%User{}, %Comment{}), do: false
end
