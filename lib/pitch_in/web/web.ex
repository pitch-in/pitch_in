defmodule PitchIn.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use PitchIn.Web, :controller
      use PitchIn.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import PitchIn.Web.ModelHelpers
      import PitchIn.Web.Helpers
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: PitchIn.Web

      alias PitchIn.Repo
      import Ecto
      import Ecto.Query

      import PitchIn.Web.Router.Helpers
      import PitchIn.Web.Gettext
      import PitchIn.Web.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/pitch_in/web/templates", namespace: PitchIn.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import PitchIn.Web.Router.Helpers
      import PitchIn.Web.ViewHelpers
      import PitchIn.Web.ErrorHelpers
      import PitchIn.Web.Gettext
      import PitchIn.Web.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias PitchIn.Repo
      import Ecto
      import Ecto.Query
      import PitchIn.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
