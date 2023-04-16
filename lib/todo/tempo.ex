defmodule Todo.Tempo do
  @moduledoc """
  This module provides functions to work with dates and times 
  """
  @default_duration 15

  @doc """
  Wrapper for DateTime.now!(timezone)
  """
  defdelegate now!(timezone), to: DateTime

  @doc """
  Given a timezone, it returns just the date for today

  ## Examples

      iex> Todo.Tempo.today_date("Etc/UTC")
      ~D[2023-01-27]

  """
  def today_date(timezone), do: DateTime.to_date(now!(timezone))

  @doc """
  Compare 2 dates to check if they are the same

  ## Examples

      iex> Todo.Tempo.same_date?(~D[2023-01-27], ~D[2023-01-27])
      true

  """
  def same_date?(%Date{} = date_1, %Date{} = date_2), do: equal?(date_1, date_2)

  @doc """
  Compare 2 datetimes to check if they are the same

  ## Examples

      iex> Todo.Tempo.equal?(~D[2023-01-27], ~D[2023-01-27])
      true

  """
  def equal?(date_1, date_2), do: Timex.equal?(date_1, date_2)

  @doc """
  Output list of NaiveDateTime via selected date, timezone and duration


  ## Examples

      iex> date = ~D[2000-01-01]
      ~D[2000-01-01] 
      
      iex> timezone = "Etc/Utc"
      "Etc/UTC" 
      
      iex> step = 20
      20
      
      iex> list_of_times(date, timezone, step)
      [NaiveDateTime, ...]
  """
  @spec list_of_times(Date.t() | nil, String.t(), Integer.t()) :: List.t()
  def list_of_times(selected_date \\ nil, timezone, step \\ @default_duration)

  def list_of_times(nil, timezone, step), do: do_list_of_times(true, timezone, step)

  def list_of_times(selected_date, timezone, step) do
    selected_date = Date.from_iso8601!(selected_date)

    today_date = today_date(timezone)

    selected_date
    |> same_date?(today_date)
    |> do_list_of_times(timezone, step)
  end

  defp do_list_of_times(false = _same_day, _timezone, step),
    do: create_time_intervals(~D[2000-01-22], [days: 1], step)

  defp do_list_of_times(true = _same_day, timezone, step) do
    %{minute: minute} = datetime_now = now!(timezone)

    minutes_ceil = fn minute, precision ->
      case precision - rem(minute, precision) do
        0 -> minute
        minutes_left -> minutes_left
      end
    end

    dt_updated =
      datetime_now
      |> Timex.shift(minutes: minutes_ceil.(minute, step))
      |> Timex.set(second: 0, microsecond: {000_000, 6})

    dt_naive =
      dt_updated
      |> DateTime.to_date()
      |> NaiveDateTime.new!(DateTime.to_time(dt_updated))

    create_time_intervals(dt_naive, Timex.end_of_day(dt_naive), step)
  end

  defp create_time_intervals(datetime, end_of_day, step) do
    [from: datetime, until: end_of_day, right_open: false]
    |> Timex.Interval.new()
    |> Timex.Interval.with_step(minutes: step)
    |> Enum.map(& &1)
  end
end
