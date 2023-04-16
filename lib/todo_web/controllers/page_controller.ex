defmodule TodoWeb.PageController do
  use TodoWeb, :controller

  def index(conn, _params) do
    # token = get_session(conn, "token")

    # client = Map.merge(Google.client(), %{token: token})

    # link = "http://one-to-one.app"

    # event = %{
    #   calendar_id: "primary",
    #   id: "12352abc",
    #   sendNotifications: true,
    #   sendUpdates: "all",
    #   description:
    #     "kindly click this link to go straight to your video-conference <a href=#{link}>one-to-one link</a>",
    #   visibility: "private",
    #   summary: "Upcoming One-to-One meeting",
    #   attendees: [
    #     %{
    #       email: "jethro.riosa@gmail.com",
    #       responseStatus: "needsAction",
    #       comment: ""
    #     },
    #     %{
    #       email: "riosa.pau@gmail.com",
    #       responseStatus: "needsAction",
    #       comment: ""
    #     }
    #   ],
    #   start: %{
    #     dateTime: "2023-02-24T08:30:00+08:00",
    #     timezone: "Asia/Manila"
    #   },
    #   end: %{
    #     dateTime: "2023-02-24T09:00:00+08:00",
    #     timezone: "Asia/Manila"
    #   }
    # }

    # GoogleCalendar.Event.insert(client, event)
    # |> raise

    render(conn, "index.html")
  end
end
