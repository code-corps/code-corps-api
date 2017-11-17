defmodule CodeCorps.Validators.TimeValidatorTest do
  use ExUnit.Case, async: true

  import CodeCorps.Validators.TimeValidator

  @previous_time DateTime.utc_now

  describe "validate_time_not_before/2" do
    test "when the time happened before" do
      # set the time to 1 day before the previous (recorded) time
      new_time = @previous_time |> Timex.shift(days: -1)
      changeset = cast_times(@previous_time, new_time, :modified_at)
      changeset = changeset |> validate_time_not_before(:modified_at)
      refute changeset.valid?
    end

    test "when the time happened at the same time" do
      new_time = @previous_time
      changeset = cast_times(@previous_time, new_time, :modified_at)
      changeset = changeset |> validate_time_not_before(:modified_at)
      assert changeset.valid?
    end

    test "when the time happened at the same second but with microseconds of difference" do
      previous_time = @previous_time |> Timex.shift(milliseconds: 500)
      new_time = previous_time |> truncate(:second)
      changeset = cast_times(previous_time, new_time, :modified_at)
      changeset = changeset |> validate_time_not_before(:modified_at)
      assert changeset.valid?
    end

    test "when the time happened after" do
      # set the time to 1 day after the previous (recorded) time
      new_time = @previous_time |> Timex.shift(days: 1)
      changeset = cast_times(@previous_time, new_time, :modified_at)
      changeset = changeset |> validate_time_not_before(:modified_at)
      assert changeset.valid?
    end
  end

  defp cast_times(previous_time, new_time, field) do
    data = Map.put(%{}, field, previous_time)
    fields = Map.put(%{}, field, :utc_datetime)
    params = Map.put(%{}, field, new_time)
    Ecto.Changeset.cast({data, fields}, params, [field])
  end
end
