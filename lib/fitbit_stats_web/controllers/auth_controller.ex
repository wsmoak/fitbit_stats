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

    conn
    |> put_flash(:info, "Hello #{user_name}!")
    |> redirect(to: "/")
  end
end
