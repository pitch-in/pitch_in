defmodule PitchIn.Web.ErrorViewTest do
  use PitchIn.Web.ConnCase, async: true

  alias PitchIn.Web.ErrorView

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html", %{conn: conn} do
    assert render_to_string(ErrorView, "404.html", conn: conn) =~
           "404 Page Not Found"
  end

  test "render 500.html", %{conn: conn} do
    assert render_to_string(ErrorView, "500.html", conn: conn) =~
           "It looks like we're having some technical issues."
  end

  test "render any other", %{conn: conn} do
    assert render_to_string(ErrorView, "505.html", conn: conn) =~
           "It looks like we're having some technical issues."
  end
end
