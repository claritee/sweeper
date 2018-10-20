defmodule Sweeper do
  def find_match(event, events) do
    Enum.map(sort(events), &edit_event(event, &1))
    |> insert_new_event(event)
    |> Enum.reject(&is_nil/1)
    |> sort
  end

  defp sort(events) do
    Enum.sort_by(events, fn event -> event.start_date end)
  end

  # NOTE: Hack to insert the new event. In real use, insertion/deletion/update would occur at the time of finding intersecting events.
  defp insert_new_event(result, event = %{start_date: start_date, end_date: _, type: type}) when type != :available do
    intersecting_event = Enum.find(result, fn(%{start_date: s, end_date: e, type: t}) ->
      type == t && start_date >= s && start_date <= e
    end)
    if intersecting_event, do: Enum.uniq(result), else: Enum.uniq(List.insert_at(result, -1, event))
  end

  defp insert_new_event(result, _), do: result

  # new event overlaps on same dates as existing event
  defp edit_event(event1 = %{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2})
       when (s1 == s2 and e1 == e2) do
    if t1 == :available do
      nil # delete existing event
    else
      event1 #change type of existing event
    end
  end

  # new event start date begins with in another event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2, type: t2})
    when (s1 > s2 and s1 < e2) do
    cond do
      t1 == t2 ->
        %{start_date: s2, end_date: e1, type: t1} # insert and update existing
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

  # new event end date is within another event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2, type: t2})
       when (e1 > s2 and e1 <= e2) do
    if t1 == t2 do
      %{start_date: s1, end_date: e2, type: t2} # update existing (end date shifts)
    else
      %{start_date: e1, end_date: e2, type: t2} # update existing (start date shifts)
    end
  end


  # New event is after existing event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, event = %{start_date: s2, end_date: e2, type: t2})
    when s1 >= e2 do
    if s1 == e2 && t1 == t2 do
      %{start_date: s2, end_date: e1, type: t1}
    else
      event
    end
  end

  # New event is before existing event
  defp edit_event(%{start_date: s1, end_date: e1, type: t1}, event2 = %{start_date: s2, end_date: e2, type: t2})
    when e1 <= s2 do
    cond do
      e1 == s2 && t1 == t2 ->
        %{start_date: s1, end_date: e2, type: t1}
      true ->
        event2
      end
  end

  defp edit_event(_, _), do: false
end