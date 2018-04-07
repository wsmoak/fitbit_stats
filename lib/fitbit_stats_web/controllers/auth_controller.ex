defmodule FitbitStatsWeb.AuthController do
  use FitbitStatsWeb, :controller

  def index(conn, _params) do
    redirect conn, external: Fitbit.authorize_url!(scope: "settings sleep")
  end
end
