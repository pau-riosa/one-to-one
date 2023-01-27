defmodule Todo.Tempo do
  @moduledoc """
  This module provides functions to work with dates
  """

  @doc """
  Given a timezone, it returns just the date for today

  ## Examples

      iex> Todo.Tempo.Hello.today_date("Etc/UTC")
      ~D[2023-01-27]

  """
  def today_date(timezone) do
    DateTime.to_date(now!(timezone))
  end

  @doc """
  Wrapper for DateTime.now!(timezone)
  """
  defdelegate now!(timezone), to: DateTime

  @doc """
  Compare 2 dates to check if they are the same

  ## Examples

      iex> Todo.Tempo.Hello.same_day?(~D[2023-01-27], ~D[2023-01-27])
      true

  """
  def same_day?(%Date{} = date_1, %Date{} = date_1), do: true
  def same_day?(%Date{} = _date_1, %Date{} = _date_2), do: false
end
