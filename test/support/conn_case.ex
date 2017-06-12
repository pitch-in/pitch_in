defmodule PitchIn.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  import PitchIn.Factory
  import Plug.Conn

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias PitchIn.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import PitchIn.Web.Router.Helpers

      import PitchIn.Factory
      import PitchIn.Web.ConnCase

      # The default endpoint for testing
      @endpoint PitchIn.Web.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PitchIn.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PitchIn.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def login(conn) do
    user = insert!(:user)

    conn
    |> assign(:current_user, user)
  end
end
