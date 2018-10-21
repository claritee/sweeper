defmodule Sweeper do
  def find_match(event, events) do
    # insert event into list
    events
    |> sort
    |> Enum.map(&edit_event(event, &1))
    |> List.flatten
    |> Enum.reject(&is_nil/1)
    |> List.insert_at(0, event)
    |> Enum.reject(fn(%{type: type}) -> type == :available end)
    |> sort
    |> Enum.uniq
    # Note: ideally we want to merge any dates that are on the boundary of a neighbouring event
  end

  defp sort(events) do
    Enum.sort_by(events, fn event -> event.start_date end)
  end

  # Logic to be used in SQL
#  defp intersect?(%{start_date: s1, end_date: e1}, %{start_date: s2, end_date: e2}) do
#    (s1 >= s2 and s1 < e2) || (e1 > s2 and e1 <= e2) || (s1 == s2 and e1 == e2)
#  end

  # new event overlaps on same dates as existing event
  defp edit_event(event1 = %{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2})
       when (s1 == s2 and e1 == e2) do
    if t1 == :available do
      nil # delete existing events
    else
      event1 #change type of existing event
    end
  end

  # new event starts and ends within another event
  defp edit_event(event1 = %{start_date: s1, end_date: e1, type: t1}, event2 = %{start_date: s2, end_date: e2, type: t2})
    when s1 > s2 and e1 < e2 do
    cond do
      t1 == t2 ->
        event2
      t1 == :available ->
        [%{start_date: s2, end_date: s1, type: t2}, %{start_date: e1, end_date: e2, type: t2}]
      true ->
        event1
    end
  end

  # new event start date begins with in another event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2, type: t2})
    when (s1 > s2 and s1 < e2) do
    cond do
      t1 == t2 ->
        end_date = if e2 > e1, do: e2, else: e1
        [%{start_date: s2, end_date: s1, type: t1}, %{start_date: s1, end_date: end_date, type: t1}] # insert and update existing
      # TODO: do these other cases change?
      t1 == :available ->
        %{start_date: s2, end_date: s1, type: t2} # insert and update existing
      t1 == :unavailable ->
        %{start_date: s2, end_date: s1, type: t2} # insert and update existing
      t1 == :part_time ->
        %{start_date: s2, end_date: s1, type: t2} # insert and update existing
      true ->
        %{start_date: s2, end_date: e2, type: t2} # no change
    end
  end

  # New event starts before existing event and ends after existing event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, event = %{start_date: s2, end_date: e2, type: t2})
     when s1 <= s2 and e1 >= e2, do: nil

  # new event end date is within another event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2, type: t2})
     when (e1 > s2 and e1 <= e2), do: %{start_date: e1, end_date: e2, type: t2}

  # New event is after existing event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, event = %{start_date: s2, end_date: e2, type: t2})
    when s1 >= e2, do: event

  # New event is before existing event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, event = %{start_date: s2, end_date: e2, type: t2})
    when e1 <= s2, do: event

  defp edit_event(_, _), do: false
end