defmodule SweeperTest do
  use ExUnit.Case
  doctest Sweeper
  describe "new event does not overlap existing event" do
    test "new event is after existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(1, 7, :unavailable)]) == [event(1, 7, :unavailable), event(10, 15, :unavailable)]
    end
    test "new event is after: starts on the end date of existing event" do
      result = [event(3, 15, :unavailable)]
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(3, 10, :unavailable)]) == result
    end
    # TODO fix
    test "new event is before: ends on the start date of existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(15, 18, :unavailable)]) == [event(10, 18, :unavailable)]
    end
    test "new event is before the start date of existing event" do
      assert Sweeper.find_match(event(10, 15, :unavailable), [event(16, 18, :unavailable)]) == [event(10, 15, :unavailable), event(16, 18, :unavailable)]
    end
  end

  describe "new event start date overlaps existing event" do
    test "events are of same type" do
      result = Sweeper.find_match(event(10, 15, :unavailable), [event(8, 11, :unavailable)])
      assert result == [event(8, 15, :unavailable)]
    end

    test "available overlaps existing unavailable event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(8, 11, :unavailable)])
      assert result == [event(8, 10, :unavailable)]
    end

    test "available overlaps an existing part time event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(8, 11, :part_time)])
      assert result == [event(8, 10, :part_time)]
    end

    test "overlaps a part time event" do
      result = Sweeper.find_match(event(10, 15, :unavailable), [event(8, 11, :part_time)])
      assert result == [event(8, 10, :part_time), event(10, 15, :unavailable)]
    end

    test "overlaps an existing unavailable event" do
      result = Sweeper.find_match(event(10, 15, :part_time), [event(8, 11, :unavailable)])
      assert result == [event(8, 10, :unavailable), event(10, 15, :part_time)]
    end
  end

  describe "new event end date overlaps with existing event" do
    test "available begins in unavailable event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(12, 17, :unavailable)])
      assert [event(15, 17, :unavailable)] == result
    end
    test "available begins in part time event" do
      result = Sweeper.find_match(event(10, 15, :available), [event(12, 17, :part_time)])
      assert [event(15, 17, :part_time)] == result

      result = Sweeper.find_match(event(10, 12, :available), [event(12, 17, :part_time)])
      assert [event(12, 17, :part_time)] == result
    end
    test "begins in unavailable event" do
      result = Sweeper.find_match(event(10, 15, :part_time), [event(12, 17, :unavailable)])
      assert [event(10, 15, :part_time), event(15, 17, :unavailable)] == result

      result = Sweeper.find_match(event(10, 12, :part_time), [event(12, 17, :unavailable)])
      assert [event(10, 12, :part_time), event(12, 17, :unavailable)] == result
    end
    test "begins in part time event" do
      result = Sweeper.find_match(event(10, 15, :unavailable), [event(12, 17, :part_time)])
      assert [event(10, 15, :unavailable), event(15, 17, :part_time)] == result

      result = Sweeper.find_match(event(10, 12, :unavailable), [event(12, 17, :part_time)])
      assert [event(10, 12, :unavailable), event(12, 17, :part_time)] == result
    end
    test "begins in same type of event" do
      result = Sweeper.find_match(event(10, 15, :part_time), [event(12, 17, :part_time)])
      assert [event(10, 17, :part_time)] == result
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

  describe "new event is inserted between existing events" do
    test "event type start and end boundary, different event type" do
      # event is inserted
    end
    test "event type start and end boundary, availability event type" do
      # no event inserted
    end
    test "event type start and end boundary, same event type" do
      # event not inserted, left event end date adjusted, right event removed
    end
    test "event type start and end overlap, availability event type" do
      # event not inserted, left event end date adjusted, right event start date adjusted
    end
  end

  describe "available event overlaps with unavailable and part time events" do
    test "available event start date is the same" do
    end
    test "available event end date is the same" do
    end
    test "available event start and end date between" do
    end
    test "available event start and end date between" do
    end
  end

  defp event(start_date, end_date, type) do
    %{start_date: start_date, end_date: end_date, type: type}
  end
end
