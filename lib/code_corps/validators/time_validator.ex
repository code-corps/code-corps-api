defmodule CodeCorps.Validators.TimeValidator do
  @moduledoc """
  Used for validating timestamp fields in a given changeset.
  """

  alias Ecto.Changeset

  @doc """
  Validates the new time is not before the previous time.
  """
  def validate_time_not_before(%{data: data} = changeset, field) do
    previous_time = Map.get(data, field)
    current_time = Changeset.get_change(changeset, field)
    case current_time do
      nil -> changeset
      _ -> do_validate_time_not_before(changeset, field, previous_time, current_time)
    end
  end

  defp do_validate_time_not_before(changeset, field, previous_time, current_time) do
    case Timex.before?(current_time, previous_time) do
      true -> Changeset.add_error(changeset, field, "cannot be before the last recorded time")
      false -> changeset
    end
  end
end
