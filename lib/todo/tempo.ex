defmodule Todo.Tempo do
  def today_date(timezone) do
    DateTime.to_date(DateTime.now!(timezone))
  end

  defdelegate now!(timezone), to: DateTime

  def same_day?(%Date{} = date_1, %Date{} = date_1), do: true
  def same_day?(%Date{} = _date_1, %Date{} = _date_2), do: false

  def before_today?(date, timezone) do
  end
end
