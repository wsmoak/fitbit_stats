defmodule Fitbit do
  @moduledoc """
  An OAuth2 strategy for Fitbit.
  Based on the OAuth2 strategy for GitHub by Sonny Scroggin
  in https://github.com/scrogson/oauth2_example
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  defp config do
    [
      strategy: Fitbit,
      site: "https://api.fitbit.com",
      authorize_url: "https://www.fitbit.com/oauth2/authorize",
      token_url: "https://api.fitbit.com/oauth2/token",
      client_id: System.get_env("CLIENT_ID"),
      client_secret: System.get_env("CLIENT_SECRET"),
      redirect_uri: System.get_env("REDIRECT_URI")
    ]
  end

  # Public API

  def client do
    OAuth2.Client.new(config())
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Authorization", "Basic " <> Base.encode64( System.get_env("CLIENT_ID") <> ":" <> System.get_env("CLIENT_SECRET")))
    |> AuthCode.get_token(params, headers)
  end
end