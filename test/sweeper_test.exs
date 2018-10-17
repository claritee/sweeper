defmodule SweeperTest do
  use ExUnit.Case
  doctest Sweeper

  test "new event end date overlaps with existing event" do
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(12, 17, :unavailable)]) == [true]
  end

  test "new event does not overlap existing event" do
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(1, 7, :unavailable)]) == [false]
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(3, 10, :unavailable)]) == [false]
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(15, 18, :unavailable)]) == [false]
  end

  test "new event start date overlaps existing event" do
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(8, 11, :unavailable)]) == [true]
  end

  test "new event exactly overlaps existing event" do
    assert Sweeper.find_match(event(10, 15, :unavailable), [event(10, 15, :unavailable)]) == [true]
  end

  defp event(start_date, end_date, type) do
    %{start_date: start_date, end_date: end_date, type: type}
  end
end
