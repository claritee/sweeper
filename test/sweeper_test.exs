defmodule SweeperTest do
  use ExUnit.Case
  doctest Sweeper

#  test "new event end date overlaps with existing event" do
#    result = Sweeper.find_match(event(10, 15, :unavailable), [event(12, 17, :unavailable)])
#    assert {:ok, event(15, 17, :unavailable)} == result
#  end

  describe "new event does not overlap existing event" do
    test "new event is after existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(1, 7, :unavailable)]) == [event(1, 7, :unavailable), event(10, 15, :unavailable)]
    end
    test "new event is after: starts on the end date of existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(3, 10, :unavailable)]) == [event(3, 10, :unavailable), event(10, 15, :unavailable)]
    end
    test "new event is before: ends on the start date of existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(15, 18, :unavailable)]) == [event(10, 15, :unavailable), event(15, 18, :unavailable)]
    end
    test "new event is before the start date of existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(16, 18, :unavailable)]) == [event(10, 15, :unavailable), event(16, 18, :unavailable)]
    end
  end

  describe "new event overlaps existing event" do
    test "new event start date overlaps existing event of same type" do
      result = Sweeper.find_match(event(10, 15, :unavailable), [event(8, 11, :unavailable)])
      assert result == [event(8, 10, :unavailable), event(10, 15, :unavailable)]
    end

    test "available event start date overlaps an existing unavailable event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(8, 11, :unavailable)])
      assert result == [event(8, 10, :unavailable)]
    end

    test "available event start date overlaps an existing part time event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(8, 11, :part_time)])
      assert result == [event(8, 10, :part_time)]
    end

    test "unavailable event overlaps a part time event" do
      result = Sweeper.find_match(event(10, 15, :unavailable), [event(8, 11, :part_time)])
      assert result == [event(8, 10, :part_time), event(10, 15, :unavailable)]
    end

    test "part time event overlaps an unavailable event" do
      result = Sweeper.find_match(event(10, 15, :part_time), [event(8, 11, :unavailable)])
      assert result == [event(8, 10, :unavailable), event(10, 15, :part_time)]
    end
  end

  describe "new event exactly overlaps existing event" do
    test "new event is the same type" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(10, 15, :unavailable)]) == [event(10, 15, :unavailable)]
    end
    test "new event is available" do
      assert Sweeper.find_match(event(10, 15, :available), [event(10, 15, :unavailable)]) == []
    end
    test "new event is unavailable" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(10, 15, :part_time)]) == [event(10, 15, :unavailable)]
    end
    test "new event is part time" do
      assert Sweeper.find_match(event(10, 15, :part_time), [event(10, 15, :unavailable)]) == [event(10, 15, :part_time)]
    end
  end

  defp event(start_date, end_date, type) do
    %{start_date: start_date, end_date: end_date, type: type}
  end
end
