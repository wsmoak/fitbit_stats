# FitbitStats

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * set CLIENT_ID, CLIENT_SECRET, and REDIRECT_URI environment variables
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Click 'Log in with Fitbit' and authorize the app to access your data.

To interact with the app in IEX:
$ iex -S mix phx.server

To clear the User database
FitbitStats.Repo.delete_all(FitbitStats.Accounts.User)
https://hexdocs.pm/ecto/Ecto.Repo.html#c:delete_all/2