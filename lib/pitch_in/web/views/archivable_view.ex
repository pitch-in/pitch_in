defmodule PitchIn.Web.ArchivableView do
  @moduledoc """
  View & helpers for Archivable models
  """

  use PitchIn.Web, :view

  alias PitchIn.Archivable

  defmacro __using__(_) do
    quote do
      import PitchIn.Web.ArchivableView, only: [active: 1, archived: 1, archivable_index: 3, select_options: 1]
      import PitchIn.Archivable, only: [archived?: 1]
    end
  end

  def active(structs) do
    Enum.reject(structs, &Archivable.archived?/1)
  end

  def archived(structs) do
    Enum.filter(structs, &Archivable.archived?/1)
  end

  def archived_for(structs, nil), do: archived(structs)
  def archived_for(structs, list_name) do
    Enum.filter(structs, &(Archivable.archived_for?(&1, get_reasons(list_name))))
  end

  def archivable_index(name, structs, opts) do
    card = Keyword.fetch!(opts, :card)
    hide_archived = Keyword.get(opts, :hide_archived, false)
    allowed_reasons = Keyword.get(opts, :allowed_reasons, nil)

    render "index.html", name: name, items: structs, card: card, hide_archived: hide_archived, allowed_reasons: allowed_reasons
  end

  @doc """
  The options for a select input for a set of archive_reasons.
  """
  def select_options(list_name) do
    list = get_reasons(list_name)
    list = list ++ ["Other"]
    
    List.zip([list, list])
  end

  def campaign do
    [
      "Won",
      "Lost",
      "Withdrew",
      "Not enough answers",
      "Problems with volunteers"
    ]
  end

  def need do
    [
      "Filled by PitchIn",
      "Filled elsewhere",
      "No good matches",
      "No longer need help"
    ]
  end

  def volunteer_answer do
    [
      "No longer interested",
      "No longer have time",
      "Working on different campaign",
      "Campaign didn't respond"
    ]
  end

  def campaign_answer do
    [
      "Accepted",
      "Not interested",
      "Couldn't reach volunteer"
    ]
  end

  def admin_answer do
    campaign_answer ++ volunteer_answer
  end

  def get_reasons(list_name), do: apply(__MODULE__, list_name, [])
end

