defmodule FitbitStatsWeb.AuthController do
  use FitbitStatsWeb, :controller
  use Timex

  alias FitbitStats.Accounts.User
  alias FitbitStats.Repo

  def index(conn, _params) do
    redirect(conn, external: Fitbit.authorize_url!(scope: "activity nutrition profile"))
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    IO.puts("THE TOKEN IS...")
    IO.inspect(token)

    data = OAuth2.Client.get!(token, "/1/user/-/profile.json").body
    IO.puts("THE DATA IS...")
    IO.inspect(data)

    user_id = data["user"]["encodedId"]
    user_name = data["user"]["displayName"]

    changeset =
      User.changeset(%User{}, %{
        user_id: user_id,
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        name: user_name
      })

    Repo.insert!(changeset)

    # Get calories eaten this week
    mon_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-04.json").body["summary"][
        "calories"
      ]

    tues_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-05.json").body["summary"][
        "calories"
      ]

    weds_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-06.json").body["summary"][
        "calories"
      ]

    thurs_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-07.json").body["summary"][
        "calories"
      ]

    fri_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-08.json").body["summary"][
        "calories"
      ]

    sat_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-09.json").body["summary"][
        "calories"
      ]

    sun_in =
      OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2019-02-10.json").body["summary"][
        "calories"
      ]

    calories_in = mon_in + tues_in + weds_in + thurs_in + fri_in + sat_in + sun_in
    IO.puts("THE CALORIES EATEN ARE")

    IO.inspect(
      mon: mon_in,
      tues: tues_in,
      weds: weds_in,
      thurs: thurs_in,
      fri: fri_in,
      sat: sat_in,
      sun: sun_in
    )

    IO.inspect(calories_in)

    # Get calories burned this week
    mon_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-04.json").body["summary"][
        "caloriesOut"
      ]

    tues_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-05.json").body["summary"][
        "caloriesOut"
      ]

    weds_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-06.json").body["summary"][
        "caloriesOut"
      ]

    thurs_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-07.json").body["summary"][
        "caloriesOut"
      ]

    fri_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-08.json").body["summary"][
        "caloriesOut"
      ]

    sat_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-09.json").body["summary"][
        "caloriesOut"
      ]

    sun_out =
      OAuth2.Client.get!(token, "/1/user/-/activities/date/2019-02-10.json").body["summary"][
        "caloriesOut"
      ]

    calories_out = mon_out + tues_out + weds_out + thurs_out + fri_out + sat_out + sun_out
    IO.puts("THE CALORIES BURNED ARE")

    IO.inspect(
      mon: mon_out,
      tues: tues_out,
      weds: weds_out,
      thurs: thurs_out,
      fri: fri_out,
      sat: sat_out,
      sun: sun_out
    )

    IO.inspect(calories_out)

    # Calculate BMR for the rest of the day (1 calorie per minute)
    # TODO: use Fitbit's number for BMR so far today to calculate this
    now = Timex.now("America/New_York")
    end_of_day = Timex.end_of_day(now)
    # TODO: only do this if "today" is one of the days in "this week"
    bmr_today = Timex.diff(end_of_day, now, :minutes)
    # bmr_today = 0
    IO.puts("ADDING BMR CALORIES FOR TODAY")
    IO.inspect(bmr_today)

    # Desired weekly deficit
    deficit = 0
    IO.puts("ADDING DESIRED WEEKLY DEFICIT")
    IO.inspect(deficit)

    result = calories_in - calories_out - bmr_today + deficit
    IO.puts("THE DIFFERENCE IS...")
    IO.inspect(result)

    # https://community.fitbit.com/t5/Web-API-Development/Why-does-activityCalories-caloriesBMR-not-equal-caloriesOut/td-p/1258601

    conn
    |> put_flash(:info, "Hello #{user_name}! Calorie difference is #{result}")
    |> redirect(to: "/")
  end
end
