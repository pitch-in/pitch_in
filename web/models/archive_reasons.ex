defmodule PitchIn.ArchiveReasons do
  @moduledoc """
  Archive reasons for different records.
  """
  def select_options(list_atom) do
    list = apply(__MODULE__, list_atom, [])
    list = list ++ ["Other"]
    
    List.zip([list, list])
  end

  def archived?(%{archive_reason: nil}), do: false
  def archived?(%{archive_reason: _}), do: true

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

  def activist_answer do
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
      "Couldn't reach activist"
    ]
  end
end
