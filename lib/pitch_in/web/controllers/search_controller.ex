defmodule PitchIn.Web.SearchController do
  use PitchIn.Web, :controller

  alias PitchIn.Politics
  alias PitchIn.Politics.Search
  alias PitchIn.Politics.NeedSearch

  use PitchIn.Web.Auth

  def index(conn, %{"filter" => search_params}) do
    user = conn.assigns.current_user

    with {:ok, search_changeset} <- Politics.validate_search(search_params),
         {:ok, search} <- Politics.record_search(user, search_changeset),
         {:ok, results} <- Search.search(search)
    do
      search_changeset = 
        search_changeset
        |> NeedSearch.changeset
      
      conn
      |> handle_alert(user, search_params)
      |> render("index.html", changeset: search_changeset, results: results, show_alert_button: !Search.empty_search?(search))
    else
      {:error, search_changeset} ->
        conn
        |> render("index.html", changeset: search_changeset, show_alert_button: false)
    end
  end

  def index(conn, params) do
    user = conn.assigns.current_user

    search = 
      if params["clear"] do
        Search.blank_search()
      else
        Search.default_search(user)
      end

    search_changeset = NeedSearch.changeset(search)
    {:ok, results} = Search.search(search)

    conn
    |> render("index.html", changeset: search_changeset, results: results, show_alert_button: false)
  end
  
  defp handle_alert(conn, user, search_params) do
    if search_params["create_alert"] do
      # This might fail, and that's okay.
      Politics.insert_alert(user, search_params)

      conn
      |> put_flash(:success, "Alert successfully created! You can turn it off at any time under settings.")
    else
      conn
    end
  end

end
