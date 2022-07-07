defmodule TodoWeb.DashboardLive do
  use TodoWeb, :live_view

  alias Todo.Accounts
  alias Todo.Repo
  alias Timex
  alias Timex.Duration

  def mount(_params, %{"user_token" => user_token}, socket) do
    current_user = Accounts.get_user_by_session_token(user_token)
    socket = assign(socket, current_user: current_user)
    {:ok, socket}
  end

  @impl LiveView
  def handle_params(params, _uri, socket) do
    socket = assign_dates(socket, params)
    {:noreply, socket}
  end

  defp current_from_params(socket, %{"month" => month}) do
    case Timex.parse("#{month}-01", "{YYYY}-{0M}-{D}") do
      {:ok, current} -> NaiveDateTime.to_date(current)
      _ -> Timex.today(socket.assigns.timezone)
    end
  end

  defp current_from_params(socket, _) do
    Timex.today(socket.assigns.timezone)
  end

  defp assign_dates(socket, params) do
    current = current_from_params(socket, params)
    beginning_of_month = Timex.beginning_of_month(current)
    end_of_month = Timex.end_of_month(current)
    beginning_of_week = Timex.beginning_of_week(current)
    end_of_week = Timex.end_of_week(current)

    previous_month =
      beginning_of_month
      |> Timex.add(Duration.from_days(-1))
      |> date_to_month

    next_month =
      end_of_month
      |> Timex.add(Duration.from_days(1))
      |> date_to_month

    socket
    |> assign(current: current)
    |> assign(beginning_of_month: beginning_of_month)
    |> assign(end_of_month: end_of_month)
    |> assign(beginning_of_week: beginning_of_week)
    |> assign(end_of_week: end_of_week)
    |> assign(previous_month: previous_month)
    |> assign(next_month: next_month)
  end

  defp date_to_month(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}")
  end
end
