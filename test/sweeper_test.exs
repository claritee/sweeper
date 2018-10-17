defmodule SweeperTest do
  use ExUnit.Case
  doctest Sweeper

  test "new event end date overlaps with existing event" do
    assert Sweeper.find_match(event(10, 15), [event(12, 17)]) == [true]
  end

  test "new event does not overlap existing event" do
    assert Sweeper.find_match(event(10, 15), [event(1, 7)]) == [false]
    assert Sweeper.find_match(event(10, 15), [event(3, 10)]) == [false]
    assert Sweeper.find_match(event(10, 15), [event(15, 18)]) == [false]
  end

  test "new event start date overlaps existing event" do
    assert Sweeper.find_match(event(10, 15), [event(8, 11)]) == [true]
  end

  test "new event exactly overlaps existing event" do
    assert Sweeper.find_match(event(10, 15), [event(10, 15)]) == [true]
  end

  defp event(start_date, end_date) do
    %{start_date: start_date, end_date: end_date}
  end
end
