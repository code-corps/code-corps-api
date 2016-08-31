defmodule CodeCorps.Transition.UserState do
  def next(current, nil), do: nil
  def next("signed_up", "edit_profile"), do: {:ok, "edited_profile"}
  def next("edited_profile", "select_categories"), do: {:ok, "selected_categories"}
  def next("selected_categories", "select_roles"), do: {:ok, "selected_roles"}
  def next("selected_roles", "select_skills"), do: {:ok, "selected_skills"}
  def next(current, invalid_transition), do: {:error, "invalid transition #{invalid_transition} from #{current}"}
end
