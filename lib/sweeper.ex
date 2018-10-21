defmodule Sweeper do
  def find_match(event, events) do
    IO.inspect event

    sort(events)
    |> Enum.map(&intersect?(event, &1))
    |> IO.inspect
  end

  defp sort(events) do
    result = Enum.sort_by(events, fn event -> event.start_date end)
    IO.inspect result
  end

  # start within an event
  defp intersect?(%{start_date: s1, end_date: e1}, %{start_date: s2, end_date: e2})
    when (s1 >= s2 and s1 < e2), do: true

  # end within an event
  defp intersect?(%{start_date: s1, end_date: e1}, %{start_date: s2, end_date: e2})
       when (e1 > s2 and e1 <= e2), do: true

  defp intersect?(_, _), do: false
end