defmodule FitbitStatsWeb.AuthController do
  use FitbitStatsWeb, :controller

  alias FitbitStats.Accounts.User
  alias FitbitStats.Repo

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "activity nutrition profile")
  end

  def callback(conn, %{"code" => code}) do
    token = Fitbit.get_token!(code: code)
    IO.puts "THE TOKEN IS..."
    IO.inspect token

    data = OAuth2.Client.get!(token, "/1/user/-/profile.json").body
    IO.puts "THE DATA IS..."
    IO.inspect data

    user_id = data["user"]["encodedId"]
    user_name = data["user"]["displayName"]

    changeset = User.changeset(%User{},
      %{user_id: user_id,
        access_token: token.token.access_token,
        refresh_token: token.token.refresh_token,
        name: user_name
      })
    Repo.insert!(changeset)

    # Get calories eaten this week
    mon_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-14.json").body["summary"]["calories"]
    tues_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-15.json").body["summary"]["calories"]
    weds_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-16.json").body["summary"]["calories"]
    thurs_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-17.json").body["summary"]["calories"]
    fri_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-18.json").body["summary"]["calories"]
    sat_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-19.json").body["summary"]["calories"]
    sun_in = OAuth2.Client.get!(token, "/1/user/-/foods/log/date/2018-05-20.json").body["summary"]["calories"]

    calories_in = mon_in + tues_in + weds_in + thurs_in + fri_in + sat_in + sun_in
    IO.puts "THE CALORIES EATEN ARE"
    IO.inspect calories_in

    # Get calories burned this week
    mon_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-14.json").body["summary"]["caloriesOut"]
    tues_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-15.json").body["summary"]["caloriesOut"]
    weds_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-16.json").body["summary"]["caloriesOut"]
    thurs_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-17.json").body["summary"]["caloriesOut"]
    fri_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-18.json").body["summary"]["caloriesOut"]
    sat_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-19.json").body["summary"]["caloriesOut"]
    sun_out = OAuth2.Client.get!(token, "/1/user/-/activities/date/2018-05-20.json").body["summary"]["caloriesOut"]

    calories_out = mon_out + tues_out + weds_out + thurs_out + fri_out + sat_out + sun_out
    IO.puts "THE CALORIES BURNED ARE"
    IO.inspect calories_out

    result = calories_in - calories_out
    IO.puts "THE DIFFERENCE IS..."
    IO.inspect result

    # https://community.fitbit.com/t5/Web-API-Development/Why-does-activityCalories-caloriesBMR-not-equal-caloriesOut/td-p/1258601

    conn
    |> put_flash(:info, "Hello #{user_name}! Calorie difference is #{result}")
    |> redirect(to: "/")
  end
end
