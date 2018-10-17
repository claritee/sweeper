defmodule Sweeper do
  def find_match(event, events) do
    IO.inspect event

    sort(events)
    |> Enum.map(&intersect(event, &1))
    |> IO.inspect
  end

  defp sort(events) do
    result = Enum.sort_by(events, fn event -> event.start_date end)
    IO.inspect result
  end

  defp intersect(e1, e2) do
    (e1.start_date > e2.start_date && e1.start_date < e2.end_date) ||
    (e1.start_date > e2.start_date && e1.start_date < e2.start_date) ||
      (e1.end_date > e2.start_date && e1.end_date <= e2.end_date)
  end
end