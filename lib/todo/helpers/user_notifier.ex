defmodule Todo.Helpers.UserNotifier do
  import Swoosh.Email

  alias Todo.Mailer

  @support "support@one-to-one.app"

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"One-to-One", @support})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to start schedule.
  """
  def deliver_schedule_instructions(schedule, url) do
    scheduled_for =
      schedule.scheduled_for
      |> Timex.to_datetime(schedule.timezone)
      |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY} {h12}:{m} {AM}")

    deliver(
      schedule.email,
      "Upcoming Appointment with: #{schedule.created_by.first_name} #{schedule.created_by.last_name}",
      """

      ==============================

      Hi #{schedule.name},

      You have a one-to-one session with #{schedule.created_by.first_name} #{schedule.created_by.last_name} 

      this coming #{scheduled_for}

      To enter the room kindly visit this url:

      #{url}

      Please do not share this link to others. Thank you.

      ==============================
      """
    )
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
