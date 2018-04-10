defmodule FitbitStats.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :access_token, :string
    field :email, :string
    field :name, :string
    field :refresh_token, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :access_token, :refresh_token])
    |> validate_required([:name, :access_token, :refresh_token])
  end
end
