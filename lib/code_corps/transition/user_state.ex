defmodule CodeCorps.Transition.UserState do
  def next(_current, nil), do: nil

  def next("signed_up", "edit_profile"), do: {:ok, "edited_profile"}

  # Select/skip categories
  def next("edited_profile", "select_categories"), do: {:ok, "selected_categories"}
  def next("edited_profile", "skip_categories"), do: {:ok, "skipped_categories"}

  # Select/skip roles
  def next("selected_categories", "select_roles"), do: {:ok, "selected_roles"}
  def next("selected_categories", "skip_roles"), do: {:ok, "skipped_roles"}
  def next("skipped_categories", "select_roles"), do: {:ok, "selected_roles"}
  def next("skipped_categories", "skip_roles"), do: {:ok, "skipped_roles"}

  # Select/skip skills
  def next("selected_roles", "select_skills"), do: {:ok, "selected_skills"}
  def next("selected_roles", "skip_skills"), do: {:ok, "skipped_skills"}
  def next("skipped_roles", "select_skills"), do: {:ok, "selected_skills"}
  def next("skipped_roles", "skip_skills"), do: {:ok, "skipped_skills"}

  # Invalid transitions
  def next(current, invalid_transition), do: {:error, "invalid transition #{invalid_transition} from #{current}"}
end
