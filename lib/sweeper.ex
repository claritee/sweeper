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
  defp insert_new_event(result, event = %{start_date: _, end_date: _, type: t}) when t != :available do
    Enum.uniq(List.insert_at(result, -1, event))
  end
  defp insert_new_event(result, _), do: result

  defp edit_event(event1 = %{start_date: s1, end_date: e1, type: t1}, %{start_date: s2, end_date: e2})
       when (s1 == s2 and e1 == e2) do
    case t1 == :available do
      true -> nil # delete existing event e2
      _ -> event1 # :unavailable or :part_time, save or edit existing record to update the type
    end
  end

  defp edit_event(%{start_date: s1, type: t1}, %{start_date: s2, end_date: e2, type: t2})
    when (s1 > s2 and s1 < e2) do
    cond do
      t1 == t2 ->
        %{start_date: s2, end_date: s1, type: t1}
      t1 == :available ->
        %{start_date: s2, end_date: s1, type: t2}
      t1 == :unavailable ->
        %{start_date: s2, end_date: s1, type: t2}
      t1 == :part_time ->
        %{start_date: s2, end_date: s1, type: t2}
      true ->
        %{start_date: s2, end_date: e2, type: t2} # no change
    end
  end

  # TODO: what was this testing?
#  defp edit_event(%{start_date: s1}, %{start_date: s2})
#    when (s1 > s2 and s1 < s2) do
#    true
#  end

  # new event starts within another event
  defp edit_event(%{end_date: e1}, %{start_date: s2, end_date: e2})
    when (e1 > s2 and e1 <= e2) do
    true
  end

  # New event is after existing event
  defp edit_event(%{start_date: s1}, event = %{start_date: _, end_date: e2, type: _})
    when s1 >= e2, do: event

  # New event is before existing event
  defp edit_event(%{end_date: e1}, event = %{start_date: s1, end_date: _, type: _})
    when e1 <= s1, do: event

  defp edit_event(_, _), do: false
end